# Changes

## [0.4.0](https://github.com/prantlf/v-ini/compare/v0.3.5...v0.4.0) (2024-11-17)

### Features

* Support marshalling maps to sectins and unmarshalling vice versa ([24a6fb0](https://github.com/prantlf/v-ini/commit/24a6fb0dc47df8c5b272caac2a195ac2c3ea6d3f))
* Support marshalling structs to sections ([b0ad2f3](https://github.com/prantlf/v-ini/commit/b0ad2f3cccce7635fa8dd95faa6b84679110d6b1))

### Bug Fixes

* Parsed section name contained leading [ by accident ([2db09e8](https://github.com/prantlf/v-ini/commit/2db09e880d7d94400ed725980132c40d956a341a))
* Enumerating properties in section of readable ini crashed ([1381a9a](https://github.com/prantlf/v-ini/commit/1381a9ad628c29ebb8d0cd97772fd3850e7225bf))
* Allow property names with spaces ([3a8ede8](https://github.com/prantlf/v-ini/commit/3a8ede8be29db6820359d492c21e48c555d08264))
* Allow section names with spaces ([9ea175d](https://github.com/prantlf/v-ini/commit/9ea175d7e2c97132e9927132491f9461751fc99e))

### BREAKING CHANGES

Although this should not break anything, I should like to mention it. Earlier, a space in a section name failed the parsing. Now the parsing will continue, accepting the section name. There was no reason for forbidding spaces in section names. This may change the error message if the source ends in the middle of a section name. But the parsing did and will fail in this case anyway.

Although this should not break anything, I should like to mention it. Earlier, a space in a property name failed the parsing. Now the parsing will continue, accepting the property name. There was no reason for forbidding spaces in property names. This may change the error message if the source is cut before ending the last property declaration. But the parsing did and will fail in this case anyway.

## [0.3.5](https://github.com/prantlf/v-ini/compare/v0.3.4...v0.3.5) (2024-11-16)

### Bug Fixes

* Fix sources for the new V compiler ([0b85db8](https://github.com/prantlf/v-ini/commit/0b85db865e7a1492f644ba75327fe011e14f79d3))

## [0.3.4](https://github.com/prantlf/v-ini/compare/v0.3.3...v0.3.4) (2024-08-11)

### Bug Fixes

* Replace deprecated index_u8_last with last_index_u8 ([0174532](https://github.com/prantlf/v-ini/commit/01745322cc74f3dd89835bc611153b7d51f7ca1c))

## [0.3.3](https://github.com/prantlf/v-ini/compare/v0.3.2...v0.3.3) (2024-03-24)

### Bug Fixes

* Workaround for wrong scope resolution in V ([357afa0](https://github.com/prantlf/v-ini/commit/357afa0870fb380f4c38f28ace071dce26112382))

## [0.3.2](https://github.com/prantlf/v-ini/compare/v0.3.1...v0.3.2) (2024-03-24)

### Bug Fixes

* Add the now mandatory & for passing references ([3dee8d0](https://github.com/prantlf/v-ini/commit/3dee8d0876bb179684d6d864ad9af5f6971cfd20))

## [0.3.1](https://github.com/prantlf/v-ini/compare/v0.3.0...v0.3.1) (2024-02-05)

### Bug Fixes

* Workaround for wrong scope resolution in V ([bdad4f6](https://github.com/prantlf/v-ini/commit/bdad4f6484e385526aeee91a2f14d362a30f308b))

## [0.3.0](https://github.com/prantlf/v-ini/compare/v0.2.2...v0.3.0) (2024-01-28)

### Features

* Let enums be optionally marshalled as numbers ([d421a3e](https://github.com/prantlf/v-ini/commit/d421a3ec96af942110c75245753fc2d13e09c480))

### Bug Fixes

* Get options and enums working again with the new V compiler ([533e2e9](https://github.com/prantlf/v-ini/commit/533e2e91534eb852e2ac6a82294f0f90762dc6cf))

## [0.2.2](https://github.com/prantlf/v-ini/compare/v0.2.1...v0.2.2) (2023-12-11)

### Bug Fixes

* Adapt for V langage changes ([5e65325](https://github.com/prantlf/v-ini/commit/5e65325291514afb09c6ae944bcabcae93cc401e))

## [0.2.1](https://github.com/prantlf/v-ini/compare/v0.2.0...v0.2.1) (2023-10-22)

### Bug Fixes

* Fix marshalling ([4e34803](https://github.com/prantlf/v-ini/commit/4e34803538323e30faf33a52c9a342d5ff25827a))

## [0.2.0](https://github.com/prantlf/v-ini/compare/v0.1.1...v0.2.0) (2023-10-15)

### Features

* Support decoding maps ([f423ee2](https://github.com/prantlf/v-ini/commit/f423ee2b40b026d7a1c1bfdf3bfcb1a9f94cec9c))
* Support marshalling an object to a string ([a84d954](https://github.com/prantlf/v-ini/commit/a84d954e08f16acbb75249300a6217613e1f2ee9))

## [0.1.1](https://github.com/prantlf/v-ini/compare/v0.1.0...v0.1.1) (2023-09-16)

### Bug Fixes

* Correct the line number in error messages ([c0c7a68](https://github.com/prantlf/v-ini/commit/c0c7a68fd8b493f2e64070b896b2ded9463d7a71))
* Do not use module names as internal variable names ([27ba78a](https://github.com/prantlf/v-ini/commit/27ba78a0ecc7dd876ea9280c7768348d32aa9e7c))

## [0.1.0](https://github.com/prantlf/v-ini/compare/v0.0.1...v0.1.0) (2023-08-15)

### Features

* Add _readable methods as a workaround ([e03ef47](https://github.com/prantlf/v-ini/commit/e03ef47ed41ce444b5819576756f964250c31b30))

## 0.0.1 (2023-08-15)

Initial release.
