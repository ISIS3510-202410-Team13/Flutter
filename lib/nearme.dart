import 'package:flutter/material.dart';

import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class nearmeitem extends StatelessWidget {
  const nearmeitem({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){},
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(right: 15),
              child: Image.asset('assets/images/Rectangle 6.png'),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    margin: EdgeInsets.all(4),
                    child: Text(
                      'Toninos Pizza',
                      style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.w900),
                    )),
                Container(
                    margin: EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Container(
                            margin: EdgeInsets.only(right: 8),
                            child: Image.asset('assets/images/11.png')),
                        Text('9 West, Riyadh City'),
                      ],
                    )),
                Container(
                    margin: EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Container(
                            margin: EdgeInsets.only(right: 8),
                            child: Image.asset('assets/images/clock 1.png')),
                        Text('3 min - 1.1 km'),
                      ],
                    )),
              
              ],
            ),
          ],
        ),
      ),
    );
  }
}
