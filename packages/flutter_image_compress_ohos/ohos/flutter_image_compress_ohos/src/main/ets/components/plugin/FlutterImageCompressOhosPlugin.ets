import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import MethodChannel, {
  MethodCallHandler,
  MethodResult
} from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import image from '@ohos.multimedia.image';
import fs from '@ohos.file.fs';
import { BusinessError } from '@kit.BasicServicesKit';

/** FlutterImageCompressOhosPlugin **/
export default class FlutterImageCompressOhosPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private showLog: Boolean = true;

  constructor() {
  }

  getUniqueClassName(): string {
    return "FlutterImageCompressOhosPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "flutter_image_compress");
    this.channel.setMethodCallHandler(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    if (call.method == "showLog") {
      this.showLog = call.args
      result.success(null)
    }
    else if (call.method == "compressWithList") {
      let args: Map<string, ESObject> = call.args;
      let numberOfRetries: number = args.get('numberOfRetries');
      await this.tryAgain(numberOfRetries, call, result, async () => {
        // 'list': list,
        let list: Uint8Array = args.get('list');
        let buf: ArrayBuffer = list.buffer as ArrayBuffer;
        const imageSource: image.ImageSource = image.createImageSource(buf);
        return await this.compressWithImageSource(imageSource, args);
      });
    }
    else if (call.method == 'compressWithFile') {
      let args: Map<string, ESObject> = call.args;
      let numberOfRetries: number = args.get('numberOfRetries');
      await this.tryAgain(numberOfRetries, call, result, async () => {
        //  'path': path,
        let filePath: string = args.get('path');
        const imageSource: image.ImageSource = image.createImageSource(filePath);
        return await this.compressWithImageSource(imageSource, args);
      });
    }
    else if (call.method == 'compressAndGetFile') {
      let args: Map<string, ESObject> = call.args;
      let numberOfRetries: number = args.get('numberOfRetries');
      await this.tryAgain(numberOfRetries, call, result, async () => {
        let targetPath: string = args.get('targetPath');
        // 'path': path,
        // 'targetPath': targetPath,
        let filePath: string = args.get('path');
        const imageSource: image.ImageSource = image.createImageSource(filePath);
        let uint8Array = await this.compressWithImageSource(imageSource, args);
        let file = await fs.open(targetPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
        await fs.write(file.fd, uint8Array.buffer);
        await fs.close(file.fd);
        return targetPath;
      });
    }
    else {
      result.notImplemented()
    }
  }

  async tryAgain(numberOfRetries: number, call: MethodCall, result: MethodResult, doWork: () => Promise<ESObject>): Promise<void> {
    if (numberOfRetries < 0) {
      return;
    }
    try {
      result.success(await doWork());
    }
    catch (e) {
      if (this.showLog) {
        console.error(`${call.method} failed, code is ${e.code}, message is ${e.message}`);
      }
      if (numberOfRetries - 1 > 0) {
        this.tryAgain(numberOfRetries - 1, call, result, doWork);
      }
      else {
        result.error(`${e.code}`, call.method, `${e.message}`);
      }
    }
  }


  async compressWithImageSource(imageSource: image.ImageSource, args: Map<string, ESObject>): Promise<Uint8Array> {
    // {
    //   'path': path,
    //   'minWidth': minWidth,
    //   'minHeight': minHeight,
    //   'inSampleSize': inSampleSize,
    //   'quality': quality,
    //   'rotate': rotate,
    //   'autoCorrectionAngle': autoCorrectionAngle,
    //   'format': format.index,
    //   'keepExif': keepExif,
    //   'numberOfRetries': numberOfRetries,
    // }

    let options: image.DecodingOptions = {
      sampleSize: args.get('inSampleSize'),
      editable: true,
    };
    let pixelMap: PixelMap = await imageSource.createPixelMap(options);

    let exifRotate = 0;
    let minWidth: number = args.get('minWidth');
    let minHeight: number = args.get('minHeight');
    if (args.get('autoCorrectionAngle')) {
      try {
        let imageProperty = await imageSource.getImageProperty(image.PropertyKey.ORIENTATION);
        exifRotate = this.parseExifRotate(imageProperty);
      }
      catch (e) {
        if (this.showLog)
          console.error(`getImageProperty failed, code is ${e.code}, message is ${e.message}`);
      }
    }
    if (exifRotate == 270 || exifRotate == 90) {
      let tmp: number = minWidth;
      minWidth = minHeight;
      minHeight = tmp;
    }
    try {
      let imageInfo = await pixelMap.getImageInfo();
      let scale = 1 / this.calcScale(
        minWidth,
        minHeight,
        imageInfo.size.width,
        imageInfo.size.height,
      );
      await pixelMap.scale(scale, scale);
      let rotate: number = args.get('rotate');
      let targetRotate = (rotate + exifRotate) % 360;
      if (targetRotate != 0) {
       await pixelMap.rotate(targetRotate);
      }
    }
    catch (e) {
      if (this.showLog)
        console.error(`getImageInfo failed, code is ${e.code}, message is ${e.message}`);
    }


    const imagePackerApi = image.createImagePacker();

    // PixelMap编码成不同格式的存档图片（当前仅支持JPEG和WebP）
    let format: string = 'image/jpeg';
    switch (args.get('format')) {
      case 1:
        format = 'image/png'
        break;
      case 2:
        format = 'image/heic'
        break;             
      case 3:
        format = 'image/webp'
        break;
      default:
        break;
    }

    const packOptions: image.PackingOption = {
      format: format,
      quality: args.get('quality'),
    }

    let uint8Array: Uint8Array = new Uint8Array(await imagePackerApi.packing(pixelMap, packOptions));
    pixelMap.release();
    return uint8Array;
  }

  calcScale(minWidth: number, minHeight: number, width: number, height: number,): number {
    let scaleW = width / minWidth
    let scaleH = height / minHeight
    if (this.showLog) {
      console.log(`width scale = ${scaleW}`)
      console.log(`height scale = ${scaleH}`)
    }
    return Math.max(1, Math.min(scaleW, scaleH))
  }

  // 1	上	左	0°
  // 2	上	右	水平翻转
  // 3	下	右	180°
  // 4	下	左	垂直翻转
  // 5	左	上	顺时针90°+水平翻转
  // 6	右	上	顺时针90°
  // 7	右	下	顺时针90°+垂直翻转
  // 8	左	下	逆时针90°
  parseExifRotate(orientation: string): number {
    orientation = orientation.toLowerCase();
    switch (orientation) {
    // 1	上	左	0°
      case 'top-left':
        return 0;
    // 2	上	右	水平翻转
      case 'top-right':
        return 0;
    // 3	下	右	180°
      case 'bottom-right':
        return 180;
    // 4	下	左	垂直翻转
      case 'bottom-left':
        return 0;
      case 'left-top':
      // 5	左	上	顺时针90°+水平翻转
        return 90;
    // 6	右	上	顺时针90°
      case 'right-top':
        return 90;
    // 7	右	下	顺时针90°+垂直翻转
      case 'right-bottom':
        return 90;
    // 8	左	下	逆时针90°
      case 'left-bottom':
        return 270;
      default:
        break;
    }
    return 0;
  }
}


