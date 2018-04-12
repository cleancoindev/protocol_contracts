
pragma solidity ^0.4.21;

import 'zeppelin-solidity/contracts/ReentrancyGuard.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import '../shared/Debugger.sol';
import '../modifiers/GasTracker.sol';

contract B0xObjects {
    /*event LoanOrderTaken (
        address maker,
        address loanTokenAddress,
        address interestTokenAddress,
        address collateralTokenAddress,
        address feeRecipientAddress,
        address oracleAddress,
        uint loanTokenAmount,
        uint interestAmount,
        uint initialMarginAmount,
        uint maintenanceMarginAmount,
        uint lenderRelayFee,
        uint traderRelayFee,
        uint expirationUnixTimestampSec,
        bytes32 loanOrderHash
    );*/

    event LoanPositionUpdated (
        address lender,
        address trader,
        address collateralTokenAddressFilled,
        address positionTokenAddressFilled,
        uint loanTokenAmountFilled,
        uint collateralTokenAmountFilled,
        uint positionTokenAmountFilled,
        uint loanStartUnixTimestampSec,
        bool active,
        bytes32 loanOrderHash
    );

    event LogPositionTraded(
        bytes32 loanOrderHash,
        address trader,
        address sourceTokenAddress,
        address destTokenAddress,
        uint sourceTokenAmount,
        uint destTokenAmount
    );

    event LogMarginLevels(
        bytes32 loanOrderHash,
        address trader,
        uint initialMarginAmount,
        uint maintenanceMarginAmount,
        uint currentMarginAmount
    );
    
    struct LoanOrder {
        address maker;
        address loanTokenAddress;
        address interestTokenAddress;
        address collateralTokenAddress;
        address feeRecipientAddress;
        address oracleAddress;
        uint loanTokenAmount;
        uint interestAmount;
        uint initialMarginAmount;
        uint maintenanceMarginAmount;
        uint lenderRelayFee;
        uint traderRelayFee;
        uint expirationUnixTimestampSec;
        bytes32 loanOrderHash;
    }

    struct LoanPosition {
        address lender;
        address trader;
        address collateralTokenAddressFilled;
        address positionTokenAddressFilled;
        uint loanTokenAmountFilled;
        uint collateralTokenAmountFilled;
        uint positionTokenAmountFilled;
        uint loanStartUnixTimestampSec;
        bool active;
    }

    struct Counterparty {
        address counterparty;
        bytes32 loanOrderHash;
    }

    struct InterestData {
        address lender;
        address interestTokenAddress;
        uint totalAmountAccrued;
        uint interestPaidSoFar;
    }

    function buildLoanOrderStruct(
        bytes32 loanOrderHash,
        address[6] addrs,
        uint[9] uints) 
        internal
        pure
        returns (LoanOrder) {

        return LoanOrder({
            maker: addrs[0],
            loanTokenAddress: addrs[1],
            interestTokenAddress: addrs[2],
            collateralTokenAddress: addrs[3],
            feeRecipientAddress: addrs[4],
            oracleAddress: addrs[5],
            loanTokenAmount: uints[0],
            interestAmount: uints[1],
            initialMarginAmount: uints[2],
            maintenanceMarginAmount: uints[3],
            lenderRelayFee: uints[4],
            traderRelayFee: uints[5],
            expirationUnixTimestampSec: uints[6],
            loanOrderHash: loanOrderHash
        });
    }

    /*function buildLoanPositionStruct(
        address[4] addrs,
        uint[5] uints)
        internal
        pure
        returns (Loan) {

        return LoanPosition({            
            lender: addrs[0],
            trader: addrs[1],
            collateralTokenAddressFilled: addrs[2],
            positionTokenAddressFilled: addrs[3],
            loanTokenAmountFilled: uints[0],
            collateralTokenAmountFilled: uints[1],
            positionTokenAmountFilled: uints[2],
            loanStartUnixTimestampSec: uints[3],
            active: uints[4] != 0
        });
    }*/
}

// b0x shared storage
contract B0xStorage is B0xObjects, ReentrancyGuard, Ownable, GasTracker, Debugger {
    uint constant MAX_UINT = 2**256 - 1;

    address public B0X_TOKEN_CONTRACT;
    address public VAULT_CONTRACT;
    address public ORACLE_REGISTRY_CONTRACT;
    address public B0XTO0X_CONTRACT;

    mapping (bytes32 => LoanOrder) public orders; // mapping of loanOrderHash to taken loanOrders
    mapping (bytes32 => uint) public orderFilledAmounts; // mapping of loanOrderHash to loanTokenAmount filled
    mapping (bytes32 => uint) public orderCancelledAmounts; // mapping of loanOrderHash to loanTokenAmount cancelled

    mapping (bytes32 => mapping (address => LoanPosition)) public loanPositions; // mapping of loanOrderHash to mapping of traders to loanPositions
    mapping (address => Counterparty[]) public loanList; // mapping of lenders and trader addresses to array of loan Counterparty structs

    mapping (bytes32 => mapping (address => uint)) public interestPaid; // mapping of loanOrderHash to mapping of traders to amount of interest paid so far to a lender
}