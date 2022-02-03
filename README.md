# Kenshi ECVRF Consumer Contract

This repository hosts the source code of the Kenshi VRF consumer contract,
as well as the libraries required for working with VRFs and Elliptic Curves in Solidity.

Goldberg Verifiable Random Function (VRF) implementation in this repository follows the IETF VRF draft 10
located at [draft-irtf-cfrg-vrf-10](https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-vrf-10.html).
This project implements the ECVRF-SECP256K1-SHA256-TAI algorithm.

## Versioning

This project follows the following version number scheme:

```
VERSION = 0.{draft}.{revision}
```

Where `draft` is the IETF VRF draft number and `revision` is a number tracking this project's revisions.

## Usage

TODO

## License

This library is release under Apache-2.0, some functions in this implementation are inspired or copied
directly from a [Solidity VRF implementation](https://github.com/witnet/vrf-solidity) by the
[Witnet Foundation](https://github.com/witnet) as well as their implementation of an
[Elliptic Curve Solidity library](https://github.com/witnet/elliptic-curve-solidity)
both released under MIT.
