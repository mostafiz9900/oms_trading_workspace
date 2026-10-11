import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../app_pkg.dart';

class CustomCachedNetworkImageWidget extends StatelessWidget {
  const CustomCachedNetworkImageWidget({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.boxFit,
    this.radius = 8,
    this.isCircle = true,
  });

  final String imageUrl;
  final double width;
  final double height;
  final BoxFit? boxFit;
  final double radius;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
            // colorFilter:
            // const  ColorFilter.mode(Colors.red, BlendMode.colorBurn)
          ),
        ),
      ),
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius)),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade400,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(radius),
              // shape: BoxShape.circle
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => isCircle
          ? ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: SizedBox(
                height: height,
                width: height,
                // decoration: Helpers.customCircularDecoretion(
                //   context,
                //   Colors.grey.shade200,
                //   radius,
                // ),
                // child: Image.asset(
                //   AppAssets.demoProfileImagePng,
                //   fit: boxFit ?? BoxFit.cover,
                // ),
              ),
            )
          : ClipRect(
              child: Container(
                height: height,
                width: height,
                decoration: CommonWidget.customCircularDecoration(context, Colors.grey.shade200, radius),
                child: Image.asset(AssetsConstants.defoliateImageJpg, fit: boxFit ?? BoxFit.cover),
              ),
            ),
    );
  }
}
