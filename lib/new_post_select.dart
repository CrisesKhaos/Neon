// import 'package:flutter/material.dart';
// import 'package:main/new_post.dart';

// class NewPostSelect extends StatefulWidget {
//   final String user;

//   NewPostSelect(this.user);

//   @override
//   _NewPostSelectState createState() => _NewPostSelectState();
// }

// class _NewPostSelectState extends State<NewPostSelect> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Select'),
//       ),
//       body: GridView.count(
//         crossAxisCount: 2,
//         children: [
//           GestureDetector(
//             onTap: () => Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => NewPostImagePage(widget.user),
//               ),
//             ),
//             child: Card(
//               color: Colors.blue[400],
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.image,
//                     size: 50,
//                     color: Colors.white,
//                   ),
//                   Text(
//                     'Add an Image',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: () => Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => NewPostVideoPage(widget.user),
//               ),
//             ),
//             child: Card(
//               color: Colors.red,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.video_call,
//                     size: 50,
//                     color: Colors.white,
//                   ),
//                   Text(
//                     'Add a Video',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
