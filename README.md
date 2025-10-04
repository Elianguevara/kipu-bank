# KipuBank

## Descripción

KipuBank es un contrato inteligente para una bóveda bancaria descentralizada. Este contrato permite a los usuarios depositar y retirar ETH en una bóveda personal, con la seguridad de tener límites de retiro por transacción y un tope de depósito global para todo el banco, garantizando así un manejo seguro de los fondos.

El contrato sigue las mejores prácticas de seguridad en Solidity, incluyendo el patrón *checks-effects-interactions*, uso de errores personalizados para claridad y eficiencia, y comentarios NatSpec para toda la documentación del código.

## Características Principales

* **Bóveda Personal**: Cada usuario tiene su propia bóveda para depositar ETH.
* **Límite de Retiro**: Un umbral de retiro por transacción (`withdrawalThreshold`) que se establece en el despliegue para prevenir movimientos de fondos anómalos.
* **Tope de Banco**: Un límite máximo de ETH que el banco puede almacenar en total (`bankCap`), también definido en el despliegue.
* **Eventos**: Emite eventos para depósitos (`Deposit`) y retiros (`Withdrawal`), facilitando el seguimiento de la actividad del contrato.
* **Contadores**: Lleva un registro del número total de depósitos y retiros realizados.

## Despliegue con Remix IDE

### Requisitos Previos

* Tener una billetera de navegador como [MetaMask](https://metamask.io/) instalada.
* Tener ETH de prueba en la red Sepolia. Puedes obtenerlo en un *faucet* como [sepoliafaucet.com](https://sepoliafaucet.com/).

### Pasos para el Despliegue

1.  **Abrir Remix IDE:**
    Accede a [Remix IDE](https://remix.ethereum.org/) en tu navegador.

2.  **Cargar el Contrato:**
    Crea un nuevo archivo `KipuBank.sol` en el explorador de archivos de Remix y pega el código del contrato.

3.  **Compilar el Contrato:**
    * Ve a la pestaña "Solidity Compiler" (Compilador de Solidity).
    * Selecciona una versión del compilador compatible (por ejemplo, `0.8.28`).
    * Haz clic en el botón "Compile KipuBank.sol".

4.  **Desplegar en la Red Sepolia:**
    * Ve a la pestaña "Deploy & Run Transactions" (Desplegar y ejecutar transacciones).
    * En el menú desplegable "Environment", selecciona **"Injected Provider - MetaMask"**. Esto conectará Remix con tu billetera.
    * Asegúrate de que tu MetaMask esté conectada a la red de prueba **Sepolia**.
    * En la sección "Deploy", busca tu contrato `KipuBank`.
    * Junto al botón "Deploy", verás campos para los argumentos del constructor:
        * `_withdrawalThreshold`: Introduce el límite de retiro por transacción (en Wei).
        * `_bankCap`: Introduce el límite total de depósitos del banco (en Wei).
    * Haz clic en **"Deploy"** y confirma la transacción en MetaMask.

## Cómo Interactuar con el Contrato en Remix

Una vez que la transacción se confirme, tu contrato aparecerá en la sección "Deployed Contracts" (Contratos Desplegados) en Remix.

### Funciones Principales

* `deposit()`: Para depositar, introduce la cantidad de ETH que deseas enviar en el campo **"Value"** (valor) en la parte superior de la pestaña de despliegue. Luego, haz clic en el botón rojo `deposit` y confirma la transacción.
* `withdraw()`: Para retirar, introduce la cantidad en Wei en el campo `_amount` junto a la función `withdraw` y haz clic en el botón `withdraw`.
* `getVaultBalance()`: Introduce la dirección de una billetera para consultar su saldo en la bóveda.
* `getTotalBalance()`: Haz clic en este botón para ver el saldo total de ETH que tiene el contrato.

## Información del Contrato Desplegado

* **Red**: Sepolia Testnet
* **Dirección del Contrato**: `0x9c0A50af3C04B8bFE15B0161270a3E95115FdE3D`
* **Etherscan (Verificado)**: [https://sepolia.etherscan.io/address/0x9c0A50af3C04B8bFE15B0161270a3E95115FdE3D#code](https://sepolia.etherscan.io/address/0x9c0A50af3C04B8bFE15B0161270a3E95115FdE3D#code)

## Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.
