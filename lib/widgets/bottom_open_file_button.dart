import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:report_child/models/case_model.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as VidThumb;

class BottomOpenFileButton extends StatefulWidget {
  const BottomOpenFileButton({Key? key, required this.goToForm})
      : super(key: key);
  @override
  _BottomOpenFileButtonState createState() => _BottomOpenFileButtonState();
  final Function goToForm;
}

class _BottomOpenFileButtonState extends State<BottomOpenFileButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final ImagePicker _picker = ImagePicker();
        final XFile? image =
            await _picker.pickVideo(source: ImageSource.gallery);
        if (image == null) return;
        Provider.of<CaseModel>(context, listen: false).videoBytes =
            await image.readAsBytes();
        Provider.of<CaseModel>(context, listen: false).videoPath = image.path;
        Provider.of<CaseModel>(context, listen: false).videoThumbnailBytes =
            await VidThumb.VideoThumbnail.thumbnailData(
          video: image.path,
          imageFormat: VidThumb.ImageFormat.JPEG,
          maxWidth: MediaQuery.of(context).size.width.truncate(),
          quality: 100,
        );
        widget.goToForm();
      },
      child: const Padding(
        padding: EdgeInsets.only(left: 50.0, bottom: 40.0),
        child: Icon(Icons.image, size: 30, color: Colors.white),
      ),
    );
  }
}/* padding: EdgeInsets.all(5.0),
        margin: EdgeInsets.only(bottom: 10.0), */
      
