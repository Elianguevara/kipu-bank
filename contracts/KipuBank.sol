// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title KipuBank
 * @author Victor Elian Guevara
 * @notice Este contrato permite a los usuarios depositar y retirar ETH en una bóveda personal,
 * con límites de retiro y un tope de depósito global para el banco.
 * @dev Implementa el patrón checks-effects-interactions y utiliza errores personalizados.
 */
contract KipuBank {
    // ==============================================================================
    // Variables de Estado
    // ==============================================================================

    /**
     * @notice Límite máximo de ETH que se puede retirar en una sola transacción.
     * @dev Se establece en el constructor y no puede ser modificado.
     */
    uint256 public immutable withdrawalThreshold;

    /**
     * @notice Límite máximo de ETH que el banco puede tener en total.
     * @dev Se establece en el constructor y no puede ser modificado.
     */
    uint256 public immutable bankCap;

    /**
     * @notice Versión del contrato.
     * @dev Variable constante que identifica la versión actual del contrato.
     */
    string public constant VERSION = "1.0.0";

    /**
     * @notice Mapeo de la dirección de un usuario al saldo de su bóveda personal.
     * @dev Rastrea el balance individual de cada usuario en el banco.
     */
    mapping(address => uint256) public vaultBalances;

    /**
     * @notice Contador total de depósitos realizados en el contrato.
     * @dev Se incrementa con cada depósito exitoso.
     */
    uint256 public depositCount;

    /**
     * @notice Contador total de retiros realizados en el contrato.
     * @dev Se incrementa con cada retiro exitoso.
     */
    uint256 public withdrawalCount;

    // ==============================================================================
    // Eventos
    // ==============================================================================

    /**
     * @notice Se emite cuando un usuario realiza un depósito exitoso.
     * @param user La dirección del usuario que deposita.
     * @param amount La cantidad de ETH depositada.
     */
    event Deposit(address indexed user, uint256 amount);

    /**
     * @notice Se emite cuando un usuario realiza un retiro exitoso.
     * @param user La dirección del usuario que retira.
     * @param amount La cantidad de ETH retirada.
     */
    event Withdrawal(address indexed user, uint256 amount);

    // ==============================================================================
    // Errores Personalizados
    // ==============================================================================

    /**
     * @notice Error: El monto del depósito debe ser mayor que cero.
     */
    error KipuBank__ZeroDeposit();

    /**
     * @notice Error: El depósito excede el límite de capacidad del banco.
     * @param availableSpace El espacio disponible restante en el banco.
     */
    error KipuBank__BankCapExceeded(uint256 availableSpace);

    /**
     * @notice Error: El monto del retiro debe ser mayor que cero.
     */
    error KipuBank__ZeroWithdrawal();

    /**
     * @notice Error: Fondos insuficientes en la bóveda para el retiro.
     * @param balance El saldo actual del usuario.
     */
    error KipuBank__InsufficientFunds(uint256 balance);

    /**
     * @notice Error: El monto del retiro excede el umbral por transacción.
     * @param threshold El umbral máximo permitido para retiros.
     */
    error KipuBank__WithdrawalThresholdExceeded(uint256 threshold);

    /**
     * @notice Error: La transferencia de ETH falló.
     * @param reason La razón del fallo en formato bytes.
     */
    error KipuBank__TransferFailed(bytes reason);

    // ==============================================================================
    // Modificadores
    // ==============================================================================

    /**
     * @notice Modificador para verificar que el monto enviado sea mayor que cero.
     * @dev Valida que msg.value > 0 antes de ejecutar la función.
     */
    modifier nonZeroValue() {
        if (msg.value == 0) {
            revert KipuBank__ZeroDeposit();
        }
        _;
    }

    // ==============================================================================
    // Constructor
    // ==============================================================================

    /**
     * @notice Inicializa el contrato con los límites de retiro y capacidad del banco.
     * @param _withdrawalThreshold El límite de retiro por transacción.
     * @param _bankCap El límite total de depósitos del banco.
     */
    constructor(uint256 _withdrawalThreshold, uint256 _bankCap) {
        withdrawalThreshold = _withdrawalThreshold;
        bankCap = _bankCap;
    }

    // ==============================================================================
    // Funciones Externas
    // ==============================================================================

    /**
     * @notice Permite a un usuario depositar ETH en su bóveda.
     * @dev La función es 'payable' para poder recibir ETH.
     * Sigue el patrón 'checks-effects-interactions'.
     */
    function deposit() external payable nonZeroValue {
        // --- Checks ---
        uint256 currentBalance = address(this).balance - msg.value;
        uint256 newBalance = currentBalance + msg.value;
        
        if (newBalance > bankCap) {
            uint256 availableSpace = bankCap - currentBalance;
            revert KipuBank__BankCapExceeded(availableSpace);
        }

        // --- Effects ---
        vaultBalances[msg.sender] += msg.value;
        depositCount++;

        // --- Interactions ---
        // (No hay interacciones externas en esta función)

        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @notice Permite a un usuario retirar ETH de su bóveda.
     * @param _amount La cantidad de ETH a retirar.
     * @dev Sigue el patrón 'checks-effects-interactions'.
     */
    function withdraw(uint256 _amount) external {
        // --- Checks ---
        if (_amount == 0) {
            revert KipuBank__ZeroWithdrawal();
        }
        
        uint256 userBalance = vaultBalances[msg.sender];
        if (_amount > userBalance) {
            revert KipuBank__InsufficientFunds(userBalance);
        }
        
        if (_amount > withdrawalThreshold) {
            revert KipuBank__WithdrawalThresholdExceeded(withdrawalThreshold);
        }

        // --- Effects ---
        vaultBalances[msg.sender] -= _amount;
        withdrawalCount++;

        // --- Interactions ---
        _safeTransfer(msg.sender, _amount);

        emit Withdrawal(msg.sender, _amount);
    }

    // ==============================================================================
    // Funciones de Vista (View)
    // ==============================================================================

    /**
     * @notice Devuelve el saldo de la bóveda de un usuario específico.
     * @param _user La dirección del usuario.
     * @return El saldo en wei del usuario especificado.
     */
    function getVaultBalance(address _user) external view returns (uint256) {
        return vaultBalances[_user];
    }

    /**
     * @notice Devuelve el balance total del contrato.
     * @return El balance total en wei que tiene el contrato.
     */
    function getTotalBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // ==============================================================================
    // Funciones Privadas
    // ==============================================================================

    /**
     * @notice Transfiere ETH de forma segura a una dirección.
     * @dev Función privada para manejar la lógica de transferencia.
     * Utiliza call de bajo nivel para mayor seguridad.
     * @param _to La dirección a la que se enviará el ETH.
     * @param _amount La cantidad a enviar.
     */
    function _safeTransfer(address _to, uint256 _amount) private {
        (bool success, bytes memory data) = _to.call{value: _amount}("");
        if (!success) {
            revert KipuBank__TransferFailed(data);
        }
    }
}
