# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2026-07-17

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flutter_image_compress` - `v2.5.0`](#flutter_image_compress---v250)
 - [`flutter_image_compress_common` - `v1.1.0`](#flutter_image_compress_common---v110)
 - [`flutter_image_compress_macos` - `v1.1.0`](#flutter_image_compress_macos---v110)
 - [`flutter_image_compress_ohos` - `v0.0.3+1`](#flutter_image_compress_ohos---v0031)
 - [`flutter_image_compress_platform_interface` - `v1.1.0`](#flutter_image_compress_platform_interface---v110)
 - [`flutter_image_compress_web` - `v0.1.5+1`](#flutter_image_compress_web---v0151)

---

#### `flutter_image_compress` - `v2.5.0`

 - **REFACTOR**(common): drop go-flutter plugin, rebuild example native shell ([#368](https://github.com/fluttercandies/flutter_image_compress/issues/368)). ([6d3898b0](https://github.com/fluttercandies/flutter_image_compress/commit/6d3898b0ab1330f4d7679ab156478f70f5034cd6))
 - **FIX**(Android): preserve source EXIF on PNG and WebP output (refs [#130](https://github.com/fluttercandies/flutter_image_compress/issues/130)) ([#395](https://github.com/fluttercandies/flutter_image_compress/issues/395)). ([4ddf1390](https://github.com/fluttercandies/flutter_image_compress/commit/4ddf1390c6fa9ef171c3c07ffb0498529bfdb455))
 - **FIX**(iOS): preserve full source metadata on keepExif=true via direct CGImage passthrough ([#168](https://github.com/fluttercandies/flutter_image_compress/issues/168)) ([#391](https://github.com/fluttercandies/flutter_image_compress/issues/391)). ([2d6b7fe4](https://github.com/fluttercandies/flutter_image_compress/commit/2d6b7fe4b190de00e3cc298f81eb63361675d35e))
 - **FIX**(dart): reject compressAndGetFile when source == target ([#240](https://github.com/fluttercandies/flutter_image_compress/issues/240)) ([#386](https://github.com/fluttercandies/flutter_image_compress/issues/386)). ([c1dbe754](https://github.com/fluttercandies/flutter_image_compress/commit/c1dbe754b8b441f8885343451ff7353bca6f9d78))
 - **FIX**(iOS): don't crash on WebP + keepExif when ImageIO can't rewrite metadata ([#369](https://github.com/fluttercandies/flutter_image_compress/issues/369)). ([46e59a4b](https://github.com/fluttercandies/flutter_image_compress/commit/46e59a4b145659e2fab348e1e381ae8b80e60f94))
 - **FEAT**(darwin): migrate to Swift Package Manager ([#323](https://github.com/fluttercandies/flutter_image_compress/issues/323)). ([a77d6c49](https://github.com/fluttercandies/flutter_image_compress/commit/a77d6c49e5118e8990b75a2a8bf6f9e869b8ccd9))
 - **DOCS**(Android): surface HEIC + keepExif limitation via Log.w + README matrix (refs [#130](https://github.com/fluttercandies/flutter_image_compress/issues/130)) ([#394](https://github.com/fluttercandies/flutter_image_compress/issues/394)). ([3d47a609](https://github.com/fluttercandies/flutter_image_compress/commit/3d47a6094d952a560fa90d1d0889e700f902a454))

#### `flutter_image_compress_common` - `v1.1.0`

 - **REFACTOR**(common): drop go-flutter plugin, rebuild example native shell ([#368](https://github.com/fluttercandies/flutter_image_compress/issues/368)). ([6d3898b0](https://github.com/fluttercandies/flutter_image_compress/commit/6d3898b0ab1330f4d7679ab156478f70f5034cd6))
 - **FIX**(*): translate native compress failures to CompressError instead of null ([#397](https://github.com/fluttercandies/flutter_image_compress/issues/397)). ([296af9a3](https://github.com/fluttercandies/flutter_image_compress/commit/296af9a32f04e86c1cc10a836d00baedcb0770f0))
 - **FIX**(Android): preserve source EXIF on PNG and WebP output (refs [#130](https://github.com/fluttercandies/flutter_image_compress/issues/130)) ([#395](https://github.com/fluttercandies/flutter_image_compress/issues/395)). ([4ddf1390](https://github.com/fluttercandies/flutter_image_compress/commit/4ddf1390c6fa9ef171c3c07ffb0498529bfdb455))
 - **FIX**(iOS): preserve full source metadata on keepExif=true via direct CGImage passthrough ([#168](https://github.com/fluttercandies/flutter_image_compress/issues/168)) ([#391](https://github.com/fluttercandies/flutter_image_compress/issues/391)). ([2d6b7fe4](https://github.com/fluttercandies/flutter_image_compress/commit/2d6b7fe4b190de00e3cc298f81eb63361675d35e))
 - **FIX**(iOS): mkdir target parent before writeToURL (analog of [#375](https://github.com/fluttercandies/flutter_image_compress/issues/375)) ([#389](https://github.com/fluttercandies/flutter_image_compress/issues/389)). ([ed265d8f](https://github.com/fluttercandies/flutter_image_compress/commit/ed265d8f7f8cba907c6a658a96c3b0153b6986f3))
 - **FIX**(Android): recycle source bitmap in CommonHandler JPEG/PNG/WebP path ([#77](https://github.com/fluttercandies/flutter_image_compress/issues/77) [#80](https://github.com/fluttercandies/flutter_image_compress/issues/80) [#136](https://github.com/fluttercandies/flutter_image_compress/issues/136) partial) ([#388](https://github.com/fluttercandies/flutter_image_compress/issues/388)). ([2775be8b](https://github.com/fluttercandies/flutter_image_compress/commit/2775be8b01fb2363fb360c1ac8e9f98dc2dd6019))
 - **FIX**(Android): recycle HEIC bitmaps and always close HeifWriter ([#136](https://github.com/fluttercandies/flutter_image_compress/issues/136) partial) ([#387](https://github.com/fluttercandies/flutter_image_compress/issues/387)). ([38466e7b](https://github.com/fluttercandies/flutter_image_compress/commit/38466e7bebcb854e10c4bf21de5158896bc2fba7))
 - **FIX**(Android): recycle intermediate bitmaps in scale/rotate pipeline ([#77](https://github.com/fluttercandies/flutter_image_compress/issues/77) [#80](https://github.com/fluttercandies/flutter_image_compress/issues/80) partial) ([#382](https://github.com/fluttercandies/flutter_image_compress/issues/382)). ([ef837251](https://github.com/fluttercandies/flutter_image_compress/commit/ef8372518463f1d90aecc44d68b15a2dab29c7fa))
 - **FIX**(iOS): detect HEIC/HEIF/AVIF via ISO BMFF ftyp box in mime sniffer ([#381](https://github.com/fluttercandies/flutter_image_compress/issues/381)). ([8c768f00](https://github.com/fluttercandies/flutter_image_compress/commit/8c768f00a235c6491522f72dc151328a481fe4c0))
 - **FIX**(Android): delete HEIC tmp file + cache CI deps ([#321](https://github.com/fluttercandies/flutter_image_compress/issues/321) partial) ([#380](https://github.com/fluttercandies/flutter_image_compress/issues/380)). ([03230ba6](https://github.com/fluttercandies/flutter_image_compress/commit/03230ba645db60ee12876ca85de43ee1bb124d2b))
 - **FIX**(iOS): delete HEIC intermediate tmp file after read-back ([#321](https://github.com/fluttercandies/flutter_image_compress/issues/321) partial) ([#377](https://github.com/fluttercandies/flutter_image_compress/issues/377)). ([cfeb1344](https://github.com/fluttercandies/flutter_image_compress/commit/cfeb1344eaf7bb823a98470f6403b8459da05d13))
 - **FIX**(Android): preserve full EXIF and stop leaking tmp .jpg in ExifKeeper ([#376](https://github.com/fluttercandies/flutter_image_compress/issues/376)). ([31558ae4](https://github.com/fluttercandies/flutter_image_compress/commit/31558ae4033942833c6d905252c614a691acc78b))
 - **FIX**(Android): mkdirs the target path's parent before writing ([#194](https://github.com/fluttercandies/flutter_image_compress/issues/194) [#181](https://github.com/fluttercandies/flutter_image_compress/issues/181) [#90](https://github.com/fluttercandies/flutter_image_compress/issues/90)) ([#375](https://github.com/fluttercandies/flutter_image_compress/issues/375)). ([6616d101](https://github.com/fluttercandies/flutter_image_compress/commit/6616d10138f79de07b5ae5a96f6eb0b016b3e73d))
 - **FIX**(iOS): reject non-image input files instead of returning a bogus `XFile` ([#374](https://github.com/fluttercandies/flutter_image_compress/issues/374)). ([7b2f5cc1](https://github.com/fluttercandies/flutter_image_compress/commit/7b2f5cc1b770ce94044884448238b3701a2d9f0c))
 - **FIX**(Android): decode into `ARGB_8888` instead of `RGB_565` ([#373](https://github.com/fluttercandies/flutter_image_compress/issues/373)). ([96fbaf08](https://github.com/fluttercandies/flutter_image_compress/commit/96fbaf08396df8bead82f8dc8d451e85e1d809ee))
 - **FIX**(iOS): compute rotated bbox off the main thread without UIKit ([#353](https://github.com/fluttercandies/flutter_image_compress/issues/353)) ([#370](https://github.com/fluttercandies/flutter_image_compress/issues/370)). ([717690e8](https://github.com/fluttercandies/flutter_image_compress/commit/717690e8cb6ab98ce5c0c9ff46f03ab0d71c9370))
 - **FIX**(Android): don't kill the process when the input file is unreadable ([#122](https://github.com/fluttercandies/flutter_image_compress/issues/122)) ([#372](https://github.com/fluttercandies/flutter_image_compress/issues/372)). ([c88e4758](https://github.com/fluttercandies/flutter_image_compress/commit/c88e4758161612ca36de1ee61b80800ee11188da))
 - **FIX**(iOS): don't crash on WebP + keepExif when ImageIO can't rewrite metadata ([#369](https://github.com/fluttercandies/flutter_image_compress/issues/369)). ([46e59a4b](https://github.com/fluttercandies/flutter_image_compress/commit/46e59a4b145659e2fab348e1e381ae8b80e60f94))
 - **FIX**(iOS): guard HEIC encoding against nil colorSpace and silent write failures ([#358](https://github.com/fluttercandies/flutter_image_compress/issues/358)). ([aa69d225](https://github.com/fluttercandies/flutter_image_compress/commit/aa69d225a3784687648664e438f2400242078f65))
 - **FIX**: Remove AssetsLibrary usage for iOS 26 compatibility ([#366](https://github.com/fluttercandies/flutter_image_compress/issues/366)). ([966a1328](https://github.com/fluttercandies/flutter_image_compress/commit/966a13289dc9b64f4a0fa2e1a79fcb71eb01cf45))
 - **FIX**: Update commons-io dependency from 2.6 to 2.16.1+ to fix security… ([#340](https://github.com/fluttercandies/flutter_image_compress/issues/340)). ([41f996cc](https://github.com/fluttercandies/flutter_image_compress/commit/41f996cc8953da861bcd2b95182e9fc198a39740))
 - **FEAT**(Android): opt into Flutter's built-in Kotlin (KGP migration) ([#390](https://github.com/fluttercandies/flutter_image_compress/issues/390)). ([e6a8e769](https://github.com/fluttercandies/flutter_image_compress/commit/e6a8e769e1f79c4a074c2d1d3abcfe63d35ab06d))
 - **FEAT**(darwin): migrate to Swift Package Manager ([#323](https://github.com/fluttercandies/flutter_image_compress/issues/323)). ([a77d6c49](https://github.com/fluttercandies/flutter_image_compress/commit/a77d6c49e5118e8990b75a2a8bf6f9e869b8ccd9))
 - **DOCS**(Android): surface HEIC + keepExif limitation via Log.w + README matrix (refs [#130](https://github.com/fluttercandies/flutter_image_compress/issues/130)) ([#394](https://github.com/fluttercandies/flutter_image_compress/issues/394)). ([3d47a609](https://github.com/fluttercandies/flutter_image_compress/commit/3d47a6094d952a560fa90d1d0889e700f902a454))

#### `flutter_image_compress_macos` - `v1.1.0`

 - **FIX**(macOS): offload compression off the AppKit main thread ([#398](https://github.com/fluttercandies/flutter_image_compress/issues/398)). ([3d458027](https://github.com/fluttercandies/flutter_image_compress/commit/3d45802762473d46356bfb642d1d1008a50dea5a))
 - **FIX**(*): translate native compress failures to CompressError instead of null ([#397](https://github.com/fluttercandies/flutter_image_compress/issues/397)). ([296af9a3](https://github.com/fluttercandies/flutter_image_compress/commit/296af9a32f04e86c1cc10a836d00baedcb0770f0))
 - **FIX**(macOS): guard remaining force-unwraps in handleImage ([#378](https://github.com/fluttercandies/flutter_image_compress/issues/378)). ([664c18f4](https://github.com/fluttercandies/flutter_image_compress/commit/664c18f46e5cad08722481c39a8fba60e185c766))
 - **FIX**(macOS): stop crashing when CGImageDestinationCreate returns nil ([#339](https://github.com/fluttercandies/flutter_image_compress/issues/339), [#314](https://github.com/fluttercandies/flutter_image_compress/issues/314)) ([#371](https://github.com/fluttercandies/flutter_image_compress/issues/371)). ([99370c8d](https://github.com/fluttercandies/flutter_image_compress/commit/99370c8dce63f1038f3f565961d5b2cea992ecc6))
 - **FEAT**(darwin): migrate to Swift Package Manager ([#323](https://github.com/fluttercandies/flutter_image_compress/issues/323)). ([a77d6c49](https://github.com/fluttercandies/flutter_image_compress/commit/a77d6c49e5118e8990b75a2a8bf6f9e869b8ccd9))

#### `flutter_image_compress_ohos` - `v0.0.3+1`

 - **FIX**(*): translate native compress failures to CompressError instead of null ([#397](https://github.com/fluttercandies/flutter_image_compress/issues/397)). ([296af9a3](https://github.com/fluttercandies/flutter_image_compress/commit/296af9a32f04e86c1cc10a836d00baedcb0770f0))

#### `flutter_image_compress_platform_interface` - `v1.1.0`

 - **FIX**(*): translate native compress failures to CompressError instead of null ([#397](https://github.com/fluttercandies/flutter_image_compress/issues/397)). ([296af9a3](https://github.com/fluttercandies/flutter_image_compress/commit/296af9a32f04e86c1cc10a836d00baedcb0770f0))
 - **FIX**(dart): validator throws in release + names the offending path ([#189](https://github.com/fluttercandies/flutter_image_compress/issues/189) [#247](https://github.com/fluttercandies/flutter_image_compress/issues/247)) ([#383](https://github.com/fluttercandies/flutter_image_compress/issues/383)). ([c8e13e2a](https://github.com/fluttercandies/flutter_image_compress/commit/c8e13e2aa1aada428260b0067fbeab5f488f00f8))
 - **FIX**(dart): give UnsupportedFlutterImageCompress actionable error messages ([#250](https://github.com/fluttercandies/flutter_image_compress/issues/250) [#303](https://github.com/fluttercandies/flutter_image_compress/issues/303) [#235](https://github.com/fluttercandies/flutter_image_compress/issues/235)) ([#379](https://github.com/fluttercandies/flutter_image_compress/issues/379)). ([54c13e61](https://github.com/fluttercandies/flutter_image_compress/commit/54c13e611b6ed7797942502e98468b740a9cd7e9))

#### `flutter_image_compress_web` - `v0.1.5+1`

 - **FIX**(web): honor minHeight in resizeWithList (match native calcScale) ([#385](https://github.com/fluttercandies/flutter_image_compress/issues/385)). ([e572f794](https://github.com/fluttercandies/flutter_image_compress/commit/e572f794dfed27ac681391dc27e0f283a8e859d7))


## 2025-01-02

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flutter_image_compress` - `v2.4.0`](#flutter_image_compress---v240)
 - [`flutter_image_compress_macos` - `v1.0.3`](#flutter_image_compress_macos---v103)
 - [`flutter_image_compress_web` - `v0.1.5`](#flutter_image_compress_web---v015)

---

#### `flutter_image_compress` - `v2.4.0`

 - **FEAT**: remove pica from web ([#324](https://github.com/fluttercandies/flutter_image_compress/issues/324)). ([b56ce0fa](https://github.com/fluttercandies/flutter_image_compress/commit/b56ce0fa4763bf8084c26ea8e435e37e06997ba8))

#### `flutter_image_compress_macos` - `v1.0.3`

 - **FIX**: Correct image size calculation for macOS with NSImage ([#316](https://github.com/fluttercandies/flutter_image_compress/issues/316)). ([e67ddf96](https://github.com/fluttercandies/flutter_image_compress/commit/e67ddf96ad1495281d3c5ac017d153b81f95d456))

#### `flutter_image_compress_web` - `v0.1.5`

 - **FIX**: fix pica initialization to use window object instead of jsWindow for improved compatibility. ([dd5b101c](https://github.com/fluttercandies/flutter_image_compress/commit/dd5b101cfedaf3e45b1f9c056cd66c1981ce3c86))
 - **FEAT**: remove pica from web ([#324](https://github.com/fluttercandies/flutter_image_compress/issues/324)). ([b56ce0fa](https://github.com/fluttercandies/flutter_image_compress/commit/b56ce0fa4763bf8084c26ea8e435e37e06997ba8))


## 2024-05-15

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flutter_image_compress` - `v2.3.0`](#flutter_image_compress---v230)
 - [`flutter_image_compress_ohos` - `v0.0.3`](#flutter_image_compress_ohos---v003)

---

#### `flutter_image_compress` - `v2.3.0`

 - **FEAT**: Update plugin structure for OpenHarmony ([#301](https://github.com/fluttercandies/flutter_image_compress/issues/301)). ([5e999c43](https://github.com/fluttercandies/flutter_image_compress/commit/5e999c431c5dcff880b8c217e40fa7d027ca0bdc))

#### `flutter_image_compress_ohos` - `v0.0.3`

 - **FEAT**: Update plugin structure for OpenHarmony ([#301](https://github.com/fluttercandies/flutter_image_compress/issues/301)). ([5e999c43](https://github.com/fluttercandies/flutter_image_compress/commit/5e999c431c5dcff880b8c217e40fa7d027ca0bdc))
 - **FEAT**: support openharmony ([#290](https://github.com/fluttercandies/flutter_image_compress/issues/290)). ([e9f10b28](https://github.com/fluttercandies/flutter_image_compress/commit/e9f10b28e089539fe7319d7bc1779b9a2c209fc4))
 - **FEAT**: support openharmony ([#290](https://github.com/fluttercandies/flutter_image_compress/issues/290)). ([d8c3fb95](https://github.com/fluttercandies/flutter_image_compress/commit/d8c3fb95f31e9199161dbf4306b2c98c80037c13))


## 2024-03-13

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flutter_image_compress` - `v2.2.0`](#flutter_image_compress---v220)
 - [`flutter_image_compress_common` - `v1.0.5`](#flutter_image_compress_common---v105)
 - [`flutter_image_compress_macos` - `v1.0.2`](#flutter_image_compress_macos---v102)
 - [`flutter_image_compress_ohos` - `v0.0.2`](#flutter_image_compress_ohos---v002)
 - [`flutter_image_compress_platform_interface` - `v1.0.5`](#flutter_image_compress_platform_interface---v105)
 - [`flutter_image_compress_web` - `v0.1.4+1`](#flutter_image_compress_web---v0141)

---

#### `flutter_image_compress` - `v2.2.0`

 - **FEAT**: support openharmony ([#290](https://github.com/fluttercandies/flutter_image_compress/issues/290)). ([e9f10b28](https://github.com/fluttercandies/flutter_image_compress/commit/e9f10b28e089539fe7319d7bc1779b9a2c209fc4))
 - **DOCS**: The first version for OpenHarmony. ([5fcab8da](https://github.com/fluttercandies/flutter_image_compress/commit/5fcab8dac6277b36b7169962474e5af3cf88724b))

#### `flutter_image_compress_common` - `v1.0.5`

 - **DOCS**: The first version for OpenHarmony. ([5fcab8da](https://github.com/fluttercandies/flutter_image_compress/commit/5fcab8dac6277b36b7169962474e5af3cf88724b))

#### `flutter_image_compress_macos` - `v1.0.2`

 - **DOCS**: The first version for OpenHarmony. ([5fcab8da](https://github.com/fluttercandies/flutter_image_compress/commit/5fcab8dac6277b36b7169962474e5af3cf88724b))

#### `flutter_image_compress_ohos` - `v0.0.2`

 - **FEAT**: support openharmony ([#290](https://github.com/fluttercandies/flutter_image_compress/issues/290)). ([e9f10b28](https://github.com/fluttercandies/flutter_image_compress/commit/e9f10b28e089539fe7319d7bc1779b9a2c209fc4))
 - **FEAT**: support openharmony ([#290](https://github.com/fluttercandies/flutter_image_compress/issues/290)). ([d8c3fb95](https://github.com/fluttercandies/flutter_image_compress/commit/d8c3fb95f31e9199161dbf4306b2c98c80037c13))

#### `flutter_image_compress_platform_interface` - `v1.0.5`

 - **DOCS**: The first version for OpenHarmony. ([5fcab8da](https://github.com/fluttercandies/flutter_image_compress/commit/5fcab8dac6277b36b7169962474e5af3cf88724b))

#### `flutter_image_compress_web` - `v0.1.4+1`

 - **DOCS**: The first version for OpenHarmony. ([5fcab8da](https://github.com/fluttercandies/flutter_image_compress/commit/5fcab8dac6277b36b7169962474e5af3cf88724b))


## 2024-03-08

### Changes

---

Packages with breaking changes:

- There are no breaking changes in this release.

Packages with other changes:

- [`flutter_image_compress_common` - `v1.0.4`](#flutter_image_compress_common---v104)
- [`flutter_image_compress_platform_interface` - `v1.0.4`](#flutter_image_compress_platform_interface---v104)
- [`flutter_image_compress_web` - `v0.1.4`](#flutter_image_compress_web---v014)

---

#### `flutter_image_compress_common` - `v1.0.4`

- **DEPS**: Bump KGP (Kotlin Gradle Plugin) to `1.8.20`.
- **DEPS**: Bump Java source compatibility and the JVM target to `11.`

#### `flutter_image_compress_platform_interface` - `v1.0.4`

- **FEAT**: Implement `toString` for `CompressError`.

#### `flutter_image_compress_web` - `v0.1.4`

- **DEPS**: Update `js` to `>=0.6.0 <0.8.0`.

## 2023-10-20

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flutter_image_compress` - `v2.1.0`](#flutter_image_compress---v210)
 - [`flutter_image_compress_common` - `v1.0.3`](#flutter_image_compress_common---v103)
 - [`flutter_image_compress_platform_interface` - `v1.0.3`](#flutter_image_compress_platform_interface---v103)
 - [`flutter_image_compress_web` - `v0.1.3+2`](#flutter_image_compress_web---v0132)
 - [`flutter_image_compress_macos` - `v1.0.1`](#flutter_image_compress_macos---v101)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flutter_image_compress_macos` - `v1.0.1`

---

#### `flutter_image_compress` - `v2.1.0`

 - **FEAT**: support macOS ([#264](https://github.com/fluttercandies/flutter_image_compress/issues/264)). ([06ab91ed](https://github.com/fluttercandies/flutter_image_compress/commit/06ab91ed470ea2c838daeb6c654ad06dadc99f1d))
 - **DOCS**: Update README ([#266](https://github.com/fluttercandies/flutter_image_compress/issues/266)). ([235643ab](https://github.com/fluttercandies/flutter_image_compress/commit/235643ab0be9c9a39083031d9ab9de06a74241f3))
 - **DOCS**: Update README. ([1e232a10](https://github.com/fluttercandies/flutter_image_compress/commit/1e232a10c84743ab3c35e1bffda5730801506891))
 - **DOCS**: Update changelog. ([c847f5d5](https://github.com/fluttercandies/flutter_image_compress/commit/c847f5d5d03d4e727b1a83dd33e54d8d93787749))

#### `flutter_image_compress_common` - `v1.0.3`

 - **DOCS**: Update README ([#266](https://github.com/fluttercandies/flutter_image_compress/issues/266)). ([235643ab](https://github.com/fluttercandies/flutter_image_compress/commit/235643ab0be9c9a39083031d9ab9de06a74241f3))
 - **DOCS**: Update changelog. ([c847f5d5](https://github.com/fluttercandies/flutter_image_compress/commit/c847f5d5d03d4e727b1a83dd33e54d8d93787749))

#### `flutter_image_compress_platform_interface` - `v1.0.3`

 - **DOCS**: Update README ([#266](https://github.com/fluttercandies/flutter_image_compress/issues/266)). ([235643ab](https://github.com/fluttercandies/flutter_image_compress/commit/235643ab0be9c9a39083031d9ab9de06a74241f3))
 - **DOCS**: Update README. ([1e232a10](https://github.com/fluttercandies/flutter_image_compress/commit/1e232a10c84743ab3c35e1bffda5730801506891))

#### `flutter_image_compress_web` - `v0.1.3+2`

 - **DOCS**: Update README ([#266](https://github.com/fluttercandies/flutter_image_compress/issues/266)). ([235643ab](https://github.com/fluttercandies/flutter_image_compress/commit/235643ab0be9c9a39083031d9ab9de06a74241f3))
 - **DOCS**: Update README. ([1e232a10](https://github.com/fluttercandies/flutter_image_compress/commit/1e232a10c84743ab3c35e1bffda5730801506891))
 - **DOCS**: Update changelog. ([c847f5d5](https://github.com/fluttercandies/flutter_image_compress/commit/c847f5d5d03d4e727b1a83dd33e54d8d93787749))


## 2023-07-20

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flutter_image_compress` - `v2.0.4`](#flutter_image_compress---v204)
 - [`flutter_image_compress_common` - `v1.0.2`](#flutter_image_compress_common---v102)
 - [`flutter_image_compress_platform_interface` - `v1.0.2`](#flutter_image_compress_platform_interface---v102)
 - [`flutter_image_compress_web` - `v0.1.3+1`](#flutter_image_compress_web---v0131)

---

#### `flutter_image_compress` - `v2.0.4`

 - **DOCS**: Update changelog. ([c847f5d5](https://github.com/fluttercandies/flutter_image_compress/commit/c847f5d5d03d4e727b1a83dd33e54d8d93787749))

#### `flutter_image_compress_common` - `v1.0.2`

 - **DOCS**: Update changelog. ([c847f5d5](https://github.com/fluttercandies/flutter_image_compress/commit/c847f5d5d03d4e727b1a83dd33e54d8d93787749))

#### `flutter_image_compress_platform_interface` - `v1.0.2`

 - **DOCS**: Update changelog. ([c847f5d5](https://github.com/fluttercandies/flutter_image_compress/commit/c847f5d5d03d4e727b1a83dd33e54d8d93787749))

#### `flutter_image_compress_web` - `v0.1.3+1`

 - **DOCS**: Update changelog. ([c847f5d5](https://github.com/fluttercandies/flutter_image_compress/commit/c847f5d5d03d4e727b1a83dd33e54d8d93787749))

