// import 'dart:io';
//
// import 'package:auto_lubumbashi/models/form_item.dart';
// import 'package:auto_lubumbashi/themes/app_theme.dart';
// import 'package:auto_lubumbashi/utils/custom_text_eiditing_controller.dart';
// import 'package:auto_lubumbashi/utils/data.dart';
// import 'package:flutter/material.dart';
//  import 'package:image_picker/image_picker.dart';
//
//   import 'image_screen.dart';
// import 'package:image_cropper/image_cropper.dart';
// class DataInputWidget extends StatefulWidget {
//   DataInputWidget({Key? key, required this.index, required this.data })
//       : super(key: key);
//   int index;
//   FormItem data;
//   @override
//   State<DataInputWidget> createState() => _DataInputWidgetState();
// }
//
// class _DataInputWidgetState extends State<DataInputWidget> {
//   final List<String> listErrorTexts = [];
//
//   final List<String> listTexts = [];
//
//   CustomTextEdittingController _controller = CustomTextEdittingController();
//   @override
//   void initState() {
//
//     _controller = CustomTextEdittingController(listErrorTexts: listErrorTexts);
//     super.initState();
//   }
//
//   void _handleOnChange(String text) {
//     _handleSpellCheck(text, true);
//   }
//   void _handleSpellCheck(String text, bool ignoreLastWord) {
//     if (!text.contains(' ')) {
//       return;
//     }
//     final List<String> arr = text.split(' ');
//     if (ignoreLastWord) {
//       arr.removeLast();
//     }
//     for (var word in arr) {
//       if (word.isEmpty) {
//         continue;
//       } else if (_isWordHasNumberOrBracket(word)) {
//         continue;
//       }
//       final wordToCheck = word.replaceAll(RegExp(r"[^\s\w]"), '');
//       final wordToCheckInLowercase = wordToCheck.toLowerCase();
//       if (!listTexts.contains(wordToCheckInLowercase)) {
//         listTexts.add(wordToCheckInLowercase);
//         if (!listEnglishWords.contains(wordToCheckInLowercase)) {
//           listErrorTexts.add(wordToCheck);
//         }
//       }
//     }
//   }
//   bool _isWordHasNumberOrBracket(String s) {
//     return s.contains(RegExp(r'[0-9\()]'));
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width ,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 8,),
//           Padding(
//             padding: const EdgeInsets.only(left: 12,right: 20),
//             child: SizedBox(
//               width: MediaQuery.of(context).size.width ,
//               child: TextFormField(
//                 controller: _controller,
//                 onChanged: (text) {
//                   _handleOnChange(text);
//                   setState(() {
//                     widget.data.description =  text;
//                   });
//                 },
//                 decoration: InputDecoration(
//                   hintText: 'Description',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 12,
//           ),
//
//           //old image
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//
//             children: [
//               Row(
//                 children: const[
//                   SizedBox(width: 22,),
//                    Text("Please select a old image",style: TextStyle(color: Colors.black,fontSize: 13,fontWeight: FontWeight.bold),),
//                 ],
//               ),
//               Builder(
//                 builder: (context) {
//                   if(widget.data.oldImagePath.toString().isEmpty || widget.data.oldImagePath==null){
//                     return InkWell(
//                       onTap: (){
//                         selectImages("gallery", "old");
//                       },
//                       child:const Padding(
//                         padding:  EdgeInsets.all(8.0),
//                         child: Icon(Icons.add_circle,color: MyAppTheme.primaryRed,),
//                       ),
//                     );
//
//
//                   }else{
//                     return Row(
//                       children: [
//                         InkWell(
//                           onTap: (){
//                             selectImages("gallery", "old");
//                           },
//                           child: const Padding(
//                             padding:  EdgeInsets.all(8.0),
//                             child: Icon(Icons.edit,color: MyAppTheme.primaryRed,),
//                           ),
//                         ),
//                         InkWell(
//                           onTap: (){
//                             setState(() {
//                               widget.data.oldImagePath = "";
//                             });
//                           },
//                           child: const Padding(
//                             padding:  EdgeInsets.all(8.0),
//                             child: Icon(Icons.delete,color: MyAppTheme.primaryRed,),
//                           ),
//                         )
//                       ],
//                     );
//                   }
//
//                 }
//               )
//             ],
//           ),
//           const SizedBox(
//             height: 6,
//           ),
//           Builder(
//             builder: (context) {
//               if(widget.data.oldImagePath==null||widget.data.oldImagePath. toString().isEmpty){
//                 return Container();
//               }
//               return Center(
//                 child: InkWell(
//                   onTap: (){
//                     Navigator.of(context).push(MaterialPageRoute(builder: (c)=>ImageScreen(image: Image.file(File(widget.data.oldImagePath.toString())
//                       ,fit: BoxFit.cover
//                       ,errorBuilder: (a,b,c){
//                         return Container();
//                       },), index: 0)));
//                   },
//                   child: SizedBox(
//                     height: 120,
//                     width: MediaQuery.of(context).size.width-30,
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12) ,
//                       child: Image.file(File(widget.data.oldImagePath.toString())
//                         ,fit: BoxFit.cover
//                         ,errorBuilder: (a,b,c){
//                         return Container();
//                       },),
//                     ),
//                   ),
//                 ),
//               );
//             }
//           ),
//
//           ///
//           ///
//           const Divider(),
//           //new image
//
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: const[
//                   SizedBox(width: 22,),
//                   Text("Please select a new image",style: TextStyle(color: Colors.black,fontSize: 13,fontWeight: FontWeight.bold),),
//                 ],
//               ),
//               Builder(
//                   builder: (context) {
//                     if(widget.data.newImagePath.toString().isEmpty || widget.data.newImagePath==null){
//                       return InkWell(
//                         onTap: (){
//                           selectImages("gallery", "new");
//                         },
//                         child:const Padding(
//                           padding:  EdgeInsets.all(8.0),
//                           child: Icon(Icons.add_circle,color: MyAppTheme.primaryRed,),
//                         ),
//                       );
//                     }else{
//                       return Row(
//                         children: [
//                           InkWell(
//                             onTap: (){
//                               selectImages("gallery", "old");
//                             },
//                             child: const Padding(
//                               padding:  EdgeInsets.all(8.0),
//                               child: Icon(Icons.edit,color: MyAppTheme.primaryRed,),
//                             ),
//                           ),
//                           InkWell(
//                             onTap: (){
//                               setState(() {
//                                 widget.data.newImagePath = "";
//                               });
//                             },
//                             child: const Padding(
//                               padding:  EdgeInsets.all(8.0),
//                               child: Icon(Icons.delete,color: MyAppTheme.primaryRed,),
//                             ),
//                           )
//                         ],
//                       );
//                     }
//
//                   }
//               )
//             ],
//           ),
//           const SizedBox(
//             height: 6,
//           ),
//           Builder(
//               builder: (context) {
//                 if(widget.data.newImagePath==null||widget.data.newImagePath. toString().isEmpty){
//                   return Container();
//                 }
//                 return Center(
//                   child: InkWell(
//                     onTap: (){
//                       Navigator.of(context).push(MaterialPageRoute(builder: (c)=>ImageScreen(image: Image.file(File(widget.data.newImagePath.toString())
//                         ,fit: BoxFit.cover
//                         ,errorBuilder: (a,b,c){
//                           return Container();
//                         },), index: 0)));
//                     },
//                     child: SizedBox(
//                       height: 120,
//                       width: MediaQuery.of(context).size.width-30,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(12) ,
//                         child: Image.file(File(widget.data.newImagePath.toString())
//                           ,fit: BoxFit.cover
//                           ,errorBuilder: (a,b,c){
//                             return Container();
//                           },),
//                       ),
//                     ),
//                   ),
//                 );
//               }
//           ),
//         ],
//       ),
//     );
//   }
//
//     void selectImages(String type,String condition) async {
//
//     final ImagePicker imagePicker = ImagePicker();
//
//     final XFile? selectedImage = await imagePicker.pickImage(
//       source:type=='camera'? ImageSource.camera:ImageSource.gallery,
//       imageQuality: 20,
//     );
//
//     if (selectedImage!=null) {
//       final croppedFile = await ImageCropper().cropImage(
//         sourcePath: selectedImage.path,
//         compressFormat: ImageCompressFormat.jpg,
//         uiSettings: [
//           AndroidUiSettings(
//             toolbarTitle: 'Image Cropper',
//             toolbarColor: MyAppTheme.primaryRed,
//             lockAspectRatio: false,
//             activeControlsWidgetColor: MyAppTheme.primaryRed,
//             toolbarWidgetColor: Colors.white,
//           ),
//           IOSUiSettings(
//             title: 'Cropper',
//           ),
//         ],
//       );
//       if(croppedFile!=null){
//         if(condition == "new"){
//           setState(() {
//             widget.data.newImagePath = croppedFile.path;
//           });
//         }else{
//           setState(() {
//             widget.data.oldImagePath = croppedFile.path;
//           });
//         }
//       }
//     }
//   }
// }
