
// import 'package:etymology/pdfExport.dart';
// import 'package:flutter/material.dart';
// import 'package:printing/printing.dart';

// class PdfPreviewPage extends StatefulWidget {
//   const PdfPreviewPage({super.key});
//   @override
//   State createState() => _PdfPreviewPage();
// }

// class _PdfPreviewPage extends State  {
//   var isOpen = true;
//   TextEditingController usernameController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   Map data ={
//   'Orthodontics': {
//     'word': 'Orthodontics',
//     'description': 'Correction of teeth and jaw alignment',
//     'origin': "Greek ('orthos' = straight, 'odous' = tooth)",
//     'prefix': 'ortho-',
//     'suffix': '-dontics',
//     'definition': 'Dental specialty for correcting misaligned teeth',
//   },
//   'Podiatry': {
//     'word': 'Podiatry',
//     'description': 'Medical care for feet',
//     'origin': "Greek ('pous' = foot)",
//     'prefix': 'pod-',
//     'suffix': '-iatry',
//     'definition': 'Branch of medicine dealing with foot disorders',
//   },
//   'Traumatology': {
//     'word': 'Traumatology',
//     'description': 'Study of wounds and injuries',
//     'origin': "Greek ('trauma' = wound)",
//     'prefix': 'trauma-',
//     'suffix': '-logy',
//     'definition': 'Treatment of physical injuries caused by accidents or violence',
//   },
// };
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
//       body: Container(
//         padding: EdgeInsets.all(20),
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         child: PdfPreview(
//           build: (format)=>genaratePDF(data),
//         ),
//       )

//     );
//   }
// }
