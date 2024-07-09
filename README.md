# Complexity Analysis of FlexiContracts

## Overview

This repository hosts the Ethereum smart contracts used in the complexity analysis of FlexiContracts, an innovative solution for smart contract upgradability on the Ethereum blockchain. FlexiContracts aims to simplify the upgrade process by introducing a more streamlined and efficient approach compared to traditional design patterns like Proxy, Eternal Storage, Diamond, and Metamorphic contracts.

## Purpose

The purpose of this repository is to demonstrate the comparative analysis of complexity between FlexiContracts and traditional smart contract design patterns. The analysis focused on four widely-used token standards: ERC-20, ERC-721, ERC-1155, and ERC-777, each implemented in upgradable versions using the aforementioned design patterns, as well as in a base contract version that utilized the seamless upgrade mechanism provided by FlexiContracts.

## Methodology

Complexity assessments were performed using the [solidity-metrics tool](https://github.com/Consensys/solidity-metrics), which quantitatively measured and compared the complexity of each contract implementation. The results have shown that FlexiContracts consistently scores significantly lower in complexity, highlighting its reduced development overhead and enhanced efficiency.
