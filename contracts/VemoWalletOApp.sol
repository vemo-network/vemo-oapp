// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { OApp, MessagingFee, Origin } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol";
import {AddressCast} from "@layerzerolabs/lz-evm-protocol-v2/contracts/libs/AddressCast.sol";

library MsgCodec {
    function encode(address sender, bytes calldata payload) internal pure returns (bytes memory) {
        return abi.encode(sender, payload);
    }

    function decode(bytes calldata message)
        internal
        pure
        returns (address sender, bytes memory payload)
    {
        return abi.decode(message, (address, bytes));
    }
}

contract VemoWalletOApp is OApp {
    error WithdrawFailed();

    uint256 public feeBps = 5;

    constructor(address _endpoint, address _delegate) OApp(_endpoint, _delegate) Ownable(_delegate) {
        _transferOwnership(_delegate);
    }

    function execute(uint32 eid, bytes calldata payload, bytes calldata options) external payable {
        bytes memory message = MsgCodec.encode(msg.sender, payload);

        uint256 feeCorrection = (10000 + feeBps) / 2;
        uint256 lzFee = (msg.value * 10000 + feeCorrection) / (10000 + feeBps);
        MessagingFee memory fee = MessagingFee(lzFee, 0);

        _lzSend(eid, message, options, fee, payable(msg.sender));
    }

    function quote(uint32 eid, address sender, bytes calldata payload, bytes calldata options)
        external
        view
        returns (uint256 nativeFee, uint256 lzTokenFee)
    {
        bytes memory message = MsgCodec.encode(sender, payload);

        MessagingFee memory fee = _quote(eid, message, options, false);
        uint256 tbFee = fee.nativeFee * feeBps / 10000;

        return (fee.nativeFee + tbFee, fee.lzTokenFee);
    }

    function setFee(uint256 _feeBps) external onlyOwner {
        feeBps = _feeBps;
    }

    function withdraw(address payable to, uint256 amount) external onlyOwner {
        (bool success,) = to.call{value: amount}("");
        if (!success) revert WithdrawFailed();
    }

    function allowInitializePath(Origin calldata origin) public view override returns (bool) {
        return peers[origin.srcEid] == origin.sender
            || AddressCast.toAddress(origin.sender) == address(this);
    }

    function _getPeerOrRevert(uint32 eid) internal view override returns (bytes32) {
        if (peers[eid] != bytes32(0)) return peers[eid];
        return AddressCast.toBytes32(address(this));
    }

    function _payNative(uint256 _nativeFee) internal override returns (uint256 nativeFee) {
        if (msg.value < _nativeFee) revert NotEnoughNative(msg.value);
        return _nativeFee;
    }

    function _lzReceive(
        Origin calldata, // _origin
        bytes32, // _guid
        bytes calldata _message,
        address, // _executor
        bytes calldata // _extraData
    ) internal virtual override {
        (address sender, bytes memory payload) = MsgCodec.decode(_message);
        (bool success, bytes memory result) = sender.call(payload);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }
}
