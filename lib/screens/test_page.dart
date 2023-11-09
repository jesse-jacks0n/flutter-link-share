import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter/services.dart';

class FrostedGlassBackground extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return
           Container(
            child: Stack(
              children: [
                // Background Image
                Image.asset(
                  'assets/intro2.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),

                // Frosted Glass Effect Overlay
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                    // Adjust the blur intensity
                    child: Container(
                      color: Theme.of(context).colorScheme.background.withOpacity(0.5) // Adjust opacity for the glass effect
                    ),
                  ),
                ),
              ],

    ),
          );

  }
}