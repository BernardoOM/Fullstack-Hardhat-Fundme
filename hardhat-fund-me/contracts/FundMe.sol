//SPDX-License-Identifier: MIT
//Pragma
pragma solidity 0.8.8;
//Imports
import "./PriceConverter.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "hardhat/console.sol";
// Error codes
error FundMe__NotOwner();

//Interfaces, Libraries, Contracts

/*
  Get funds from users 
  withdraw funds 
  Set a minimum funding value in USD
*/
//859,757
//840,221

/** @title A contract for crowd funding
 * @author Bernardo Marquez
 * @notice This contract is to demo a sample funding contract
 * @dev This implements price feeds as our library
 */
contract FundMe {
    //Type declarations
    using PriceConverter for uint256;

    //State variables
    /*
     21,415 gas - constant  
     23,515 gas - non-constant
     21,415 * 141000000000 = $9,058545  
     23,515 * 141000000000 = $9,946845
     Casi un dolar mas de gas por no colocar constant
     en MINIMUM_USD
    */
    uint256 public constant MINIMUM_USD = 50 * 1e18;
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    /*  
      21,508 gas - immutable
      23,644 gas - non-immutable
      este keyword reduce gas cost          
    */
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    //Events and Modifiers
    /*la funcion que etiquete (use) un modifier, ejecutara primero las instrucciones del 
       modifier y luego sus instrucciones*/
    modifier onlyOwner() {
        //require(msg.sender == i_owner, "Sender is not owner!");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner(); //lo hace mas eficiente en gas cost
        }
        _; // significa ejecuta el resto del codigo de la funcion que usa este modifier
    }

    //Functions Order:
    /// constructor
    //  receive
    //  fallback
    //  external
    //  public
    //  internal
    // private
    // view / pure
    constructor(address priceFeedAddress) {
        //obtemos el address de quien hizo el deploy del contrato
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    /*receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }*/

    /**
     * @notice This function funds this contract
     * @dev This implements price feeds as our library
     */
    function fund() public payable {
        /*Queremos ser capaces de establecer 
        una cantidad minima de fondos en USD */
        /*msg.value se considera el primer parametro para cualquier Library function
        si la funcion recibiera otro parametro(s), entonces si se le pasa el valor */
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't send enough ETH!"
        ); // 1e18 == 1 * 10 ** 18 == 1000000000000000000
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    // function withdraw() public onlyOwner {
    //     /* starting index, ending index, step amount*/
    //     for (
    //         uint256 funderIndex = 0;
    //         funderIndex < s_funders.length;
    //         funderIndex++
    //     ) {
    //         address funder = s_funders[funderIndex];
    //         s_addressToAmountFunded[funder] = 0;
    //     }
    //     //resetear el array funders
    //     s_funders = new address[](0);
    //     //Procedemos a retirar los fondos de tres maneras: transfer, send, call
    //     // msg.sender = address type
    //     // payable(msg.sender) = payable address
    //     //Using transfer
    //     //payable(msg.sender).transfer(address(this).balance); //revierte automaticamente
    //     //Using send
    //     //bool sendSuccesss = payable(msg.sender).send(address(this).balance);
    //     //require(sendSuccesss, "Send failed"); // se encarga de revertir la transaccion si falla
    //     //Using Call
    //     (
    //         bool callSuccess, /* bytes memory dataReturned*/

    //     ) = payable(msg.sender).call{value: address(this).balance}(
    //             "" /*funcion*/
    //         );
    //     require(callSuccess, "Call failed"); //revierte la transaccion
    // }

    //cheaper gas cost
    function withdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool successCall, ) = i_owner.call{value: address(this).balance}("");
        require(successCall, "Call failed");
    }

    //View / Pure
    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
