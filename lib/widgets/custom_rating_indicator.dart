import 'package:flutter/material.dart';

class CustomRatingIndicator extends StatelessWidget {
  final double rating;
  final double size;

  const CustomRatingIndicator({
    super.key,
    required this.rating,
    this.size = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (rating >= index + 1) {
          // 100% full star
          return Icon(Icons.star, color: Colors.amber, size: size);
        } else if (rating > index) {
          // Fractional star (e.g. 4.8 rating will fill 80% of the 5th star)
          final double fraction = rating - index;
          return SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                // Background unrated empty star
                Icon(
                  Icons.star,
                  color: Colors.white.withOpacity(0.15),
                  size: size,
                ),
                // Foreground rated yellow star clipped to width factor
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: fraction,
                    child: Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: size,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // 0% empty star
          return Icon(
            Icons.star,
            color: Colors.white.withOpacity(0.15),
            size: size,
          );
        }
      }),
    );
  }
}
