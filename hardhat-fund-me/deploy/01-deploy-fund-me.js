// async function deployFunc(hre) {
//     console.log("hi")
//     hre.getNamedAccounts
//     hre.deployments
// }

// module.exports.default = deployFunc
/*Esta funcion es como la anterior, solo que la 
funcion es anonima*/
// module.exports = async (hre) => {
//     const { getNamedAccounts, deployments } = hre

const { getNamedAccounts, deployments, network } = require("hardhat")
const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    let ethUsdPriceFeedAddress
    if (chainId == 31337) {
        const ethUsdAggregator = await deployments.get("MockV3Aggregator")
        ethUsdPriceFeedAddress = ethUsdAggregator.address
    } else {
        ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    }
    log("----------------------------------------------------")
    log("Deploying FundMe and waiting for confirmations...")
    const fundMe = await deploy("FundMe", {
        from: deployer,
        args: [ethUsdPriceFeedAddress],
        log: true,
        // we need to wait if on a live network so we can verify properly
        waitConfirmations: network.config.blockConfirmations || 1,
    })
    log(`FundMe deployed at ${fundMe.address}`)

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        await verify(fundMe.address, [ethUsdPriceFeedAddress])
    }
}

module.exports.tags = ["all", "fundme"]

/*
Hay algo en mi codigo que no funciona...???
------------------------------------------------------*/
// const { getNamedAccounts, deployments, network } = require("hardhat")
// const { networkConfig, developmentChains } = require("../helper-hardhat-config")
// const { verify } = require("../utils/verify")

// module.exports = async ({ getNamedAccounts, deployments }) => {
//     const { deploy, log } = deployments
//     const { deployer } = await getNamedAccounts()
//     const chainId = network.config.chainID

//     let ethUsdPriceFeedAddress
//     //if (developmentChains.includes(network.name))//no funciona
//     if (chainId == 31337) {
//         const ethUsdAggregator = await deployments.get("MockV3Aggregator")
//         ethUsdPriceFeedAddress = ethUsdAggregator.address
//     } else {
//         ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
//     }
//     log("----------------------------------------------------")
//     /*what happens when we want to change chains?
//     when going for localhost or hardhat network we want to use a mock */
//     /*if the contract doesn't exist, we deploy a minimal
//       version of for our local testing  */
//     log("Deploying FundMe and waiting for confirmations...")
//     const fundMe = await deploy("FundMe", {
//         from: deployer,
//         args: [ethUsdPriceFeedAddress],
//         log: true,
//         // we need to wait if on a live network so we can verify properly
//         waitConfirmations: network.config.blockConfirmations || 1, //si no existe blockConfirmations en hardhat.config, entonces espera por la confirmacion de 1 block
//     })
//     log(`FundMe deployed at ${fundMe.address}`)
//     if (
//         !developmentChains.includes(network.name) &&
//         process.env.ETHERSCAN_API_KEY
//     ) {
//         await verify(fundMe.address, [ethUsdPriceFeedAddress])
//     }
//     log("-------------------------------------------------")
// }
// module.exports.tags = ["all", "fundme"]
