  /**
   * Execute a multi-signature transaction from this wallet using 2 signers: one from msg.sender and the other from ecrecover.
   * Sequence IDs are numbers starting from 1. They are used to prevent replay attacks and may not be repeated.
   *
   * @param toAddress the destination address to send an outgoing transaction
   * @param value the amount in Wei to be sent
   * @param data the data to send to the toAddress when invoking the transaction
   * @param expireTime the number of seconds since 1970 for which this transaction is valid
   * @param sequenceId the unique sequence id obtainable from getNextSequenceId
   * @param signature see Data Formats
   */
  function sendMultiSig(
      address toAddress,
      uint value,
      bytes data,
      uint expireTime,
      uint sequenceId,
      bytes signature
  ) public onlySigner {
    // Verify the other signer
    var operationHash = keccak256("ETHER", toAddress, value, data, expireTime, sequenceId);
    
    var otherSigner = verifyMultiSig(toAddress, operationHash, signature, expireTime, sequenceId);

    // Success, send the transaction
    if (!(toAddress.call.value(value)(data))) {
      // Failed executing transaction
      revert();
    }
    Transacted(msg.sender, otherSigner, operationHash, toAddress, value, data);
  }