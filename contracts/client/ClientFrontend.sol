pragma solidity ^0.5.15;
pragma experimental ABIEncoderV2;

import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
import { Tx } from "../libs/Tx.sol";
import { Types } from "../libs/Types.sol";
import { Transition } from "../libs/Transition.sol";
import { Offchain } from "./Offchain.sol";

contract ClientFrontend {
    using SafeMath for uint256;
    using Tx for bytes;
    using Types for Types.UserState;

    function decodeTransfer(bytes calldata encodedTx)
        external
        pure
        returns (Offchain.Transfer memory _tx)
    {
        return Offchain.decodeTransfer(encodedTx);
    }

    function decodeMassMigration(bytes calldata encodedTx)
        external
        pure
        returns (Offchain.MassMigration memory _tx)
    {
        return Offchain.decodeMassMigration(encodedTx);
    }

    function decodeCreate2Transfer(bytes calldata encodedTx)
        external
        pure
        returns (Offchain.Create2Transfer memory _tx)
    {
        return Offchain.decodeCreate2Transfer(encodedTx);
    }

    function validateAndApplyTransferTx(
        bytes calldata senderEncoded,
        bytes calldata receiverEncoded,
        Offchain.Transfer calldata _tx
    )
        external
        pure
        returns (
            bytes memory newSender,
            bytes memory newReceiver,
            Types.Result result
        )
    {
        Types.UserState memory sender = Types.decodeState(senderEncoded);
        Types.UserState memory receiver = Types.decodeState(receiverEncoded);
        uint256 tokenType = sender.tokenType;
        (sender, result) = Transition.validateAndApplySender(
            tokenType,
            _tx.amount,
            _tx.fee,
            sender
        );
        if (result != Types.Result.Ok) return (sender.encode(), "", result);
        (receiver, result) = Transition.validateAndApplyReceiver(
            tokenType,
            _tx.amount,
            receiver
        );
        return (sender.encode(), receiver.encode(), result);
    }
}
