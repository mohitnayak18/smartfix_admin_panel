// import 'package:admin_panel/api_calls/models/product_model.dart' hide ProductModel;
// import 'package:admin_panel/pages/store/store_controller.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class StoreScreen extends StatefulWidget {
//   final String? serviceId;
//   final String? serviceName;
//   const StoreScreen({
//     super.key, 
//     this.serviceId, 
//     this.serviceName});

//   @override
//   State<StoreScreen> createState() => _StoreScreenState();
// }

// class _StoreScreenState extends State<StoreScreen> {
//   late final StoreController controller;

//   @override
//   void initState() {
//     super.initState();
//     controller = Get.put(
//       StoreController(
//         serviceId: widget.serviceId,
//         serviceName: widget.serviceName,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     Get.delete<StoreController>();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _buildAppBar(),
//       body: Obx(() {
//         if (controller.isLoadingBrands.value && controller.brands.isEmpty) {
//           return _buildInitialLoading();
//         }

//         return RefreshIndicator(
//           onRefresh: controller.refreshData,
//           color: Colors.teal,
//           child: CustomScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             slivers: [
//               SliverPadding(
//                 padding: const EdgeInsets.all(16),
//                 sliver: SliverList(
//                   delegate: SliverChildListDelegate([
//                     // Show different views based on current state
//                     _buildCurrentView(),
                    
//                     const SizedBox(height: 24),
                    
//                     // Always show "All Products" section at bottom
//                     _buildAllProductsSection(),
//                   ]),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   // ==================== APP BAR ====================

//   AppBar _buildAppBar() {
//     return AppBar(
//       title: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(Icons.storefront_outlined, size: 20),
//           ),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Store",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//               if (controller.serviceName != null)
//                 Text(
//                   controller.serviceName!,
//                   style: const TextStyle(fontSize: 12, color: Colors.white70),
//                 ),
//             ],
//           ),
//         ],
//       ),
//       backgroundColor: Colors.teal,
//       foregroundColor: Colors.white,
//       elevation: 0,
//       actions: [
//         IconButton(
//           onPressed: () {
//             Get.snackbar('Info', 'Cart feature coming soon');
//           },
//           icon: const Icon(Icons.shopping_cart_outlined),
//         ),
//       ],
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
//       ),
//     );
//   }

//   // ==================== CURRENT VIEW ====================

//   Widget _buildCurrentView() {
//     switch (controller.currentView.value) {
//       case 'models':
//         return _buildModelsView();
//       case 'products':
//         return _buildProductsView();
//       case 'brands':
//       default:
//         return _buildBrandsView();
//     }
//   }

//   // ==================== BRANDS VIEW ====================

//   Widget _buildBrandsView() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const Text(
//           "Select Brand",
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           "Choose your mobile brand",
//           style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//         ),
//         const SizedBox(height: 16),

//         // Brands Grid
//         Obx(() {
//           if (controller.isLoadingBrands.value) {
//             return const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(20),
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           }

//           if (controller.brands.isEmpty) {
//             return _buildEmptyState(
//               icon: Icons.phonelink_off,
//               message: "No brands available",
//               subMessage: "Check back later",
//             );
//           }

//           return GridView.builder(
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               childAspectRatio: 0.8,
//               crossAxisSpacing: 8,
//               mainAxisSpacing: 8,
//             ),
//             itemCount: controller.brands.length,
//             itemBuilder: (context, index) {
//               final brand = controller.brands[index];
//               return _buildBrandCard(brand);
//             },
//           );
//         }),
//       ],
//     );
//   }

//   Widget _buildBrandCard(BrandModel brand) {
//     return GestureDetector(
//       onTap: () => controller.selectBrand(brand),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey.shade200),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.shade100,
//               blurRadius: 2,
//               offset: const Offset(0, 1),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Brand Image
//             Expanded(
//               flex: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(6),
//                 child: _buildBrandImage(brand.imageUrl),
//               ),
//             ),
//             // Brand Name
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.teal.shade50,
//                 borderRadius: const BorderRadius.vertical(
//                   bottom: Radius.circular(8),
//                 ),
//               ),
//               child: Text(
//                 brand.name,
//                 style: const TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 textAlign: TextAlign.center,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBrandImage(String imageUrl) {
//     if (imageUrl.isEmpty) {
//       return const Icon(Icons.phone_android, size: 24, color: Colors.grey);
//     }

//     return CachedNetworkImage(
//       imageUrl: imageUrl,
//       placeholder: (context, url) => const Center(
//         child: SizedBox(
//           height: 16,
//           width: 16,
//           child: CircularProgressIndicator(strokeWidth: 2),
//         ),
//       ),
//       errorWidget: (context, url, error) => 
//           const Icon(Icons.broken_image, size: 24, color: Colors.grey),
//       fit: BoxFit.contain,
//     );
//   }

//   // ==================== MODELS VIEW ====================

//   Widget _buildModelsView() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // Breadcrumb navigation
//         _buildBreadcrumb(
//           items: [
//             BreadcrumbItem(label: 'Brands', onTap: controller.backToBrands),
//             BreadcrumbItem(
//               label: controller.selectedBrand.value?.name ?? 'Models',
//               isLast: true,
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),

//         // Selected brand info
//         if (controller.selectedBrand.value != null)
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.teal.shade50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.teal.shade100),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   height: 32,
//                   width: 32,
//                   padding: const EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: _buildBrandImage(controller.selectedBrand.value!.imageUrl),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         controller.selectedBrand.value!.name,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         'Select model',
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//         const SizedBox(height: 16),

//         // Models Grid
//         Obx(() {
//           if (controller.isLoadingModels.value) {
//             return const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(20),
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           }

//           if (controller.models.isEmpty) {
//             return _buildEmptyState(
//               icon: Icons.device_unknown,
//               message: "No models available",
//               subMessage: "for ${controller.selectedBrand.value?.name ?? 'this brand'}",
//             );
//           }

//           return GridView.builder(
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 0.85,
//               crossAxisSpacing: 8,
//               mainAxisSpacing: 8,
//             ),
//             itemCount: controller.models.length,
//             itemBuilder: (context, index) {
//               final model = controller.models[index];
//               return _buildModelCard(model);
//             },
//           );
//         }),
//       ],
//     );
//   }

//   Widget _buildModelCard(ModelModel model) {
//     return GestureDetector(
//       onTap: () => controller.selectModel(model),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey.shade200),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.shade100,
//               blurRadius: 2,
//               offset: const Offset(0, 1),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Model Image
//             Expanded(
//               flex: 3,
//               child: Padding(
//                 padding: const EdgeInsets.all(6),
//                 child: _buildModelImage(model.imageUrl),
//               ),
//             ),
//             // Model Name
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade50,
//                 borderRadius: const BorderRadius.vertical(
//                   bottom: Radius.circular(8),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     model.name,
//                     style: const TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     'View',
//                     style: TextStyle(
//                       fontSize: 8,
//                       color: Colors.teal.shade700,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildModelImage(String imageUrl) {
//     if (imageUrl.isEmpty) {
//       return Center(
//         child: Icon(Icons.phone_android, size: 30, color: Colors.grey.shade400),
//       );
//     }

//     return CachedNetworkImage(
//       imageUrl: imageUrl,
//       placeholder: (context, url) => const Center(
//         child: SizedBox(
//           height: 20,
//           width: 20,
//           child: CircularProgressIndicator(strokeWidth: 2),
//         ),
//       ),
//       errorWidget: (context, url, error) => Center(
//         child: Icon(Icons.broken_image, size: 30, color: Colors.grey.shade400),
//       ),
//       fit: BoxFit.contain,
//     );
//   }

//   // ==================== PRODUCTS VIEW ====================

//   Widget _buildProductsView() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // Breadcrumb navigation
//         _buildBreadcrumb(
//           items: [
//             BreadcrumbItem(label: 'Brands', onTap: controller.backToBrands),
//             BreadcrumbItem(
//               label: controller.selectedBrand.value?.name ?? 'Models',
//               onTap: controller.backToModels,
//             ),
//             BreadcrumbItem(
//               label: controller.selectedModel.value?.name ?? 'Products',
//               isLast: true,
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),

//         // Selected model info
//         if (controller.selectedModel.value != null)
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.teal.shade50, Colors.white],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.teal.shade100),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   height: 40,
//                   width: 40,
//                   padding: const EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: _buildModelImage(controller.selectedModel.value!.imageUrl),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         controller.selectedModel.value!.name,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         '${controller.products.length} products',
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: Colors.teal.shade700,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//         const SizedBox(height: 16),

//         // Products Grid
//         Obx(() {
//           if (controller.isLoadingProducts.value) {
//             return const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(20),
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           }

//           if (controller.products.isEmpty) {
//             return _buildEmptyState(
//               icon: Icons.inventory_2_outlined,
//               message: "No products available",
//               subMessage: "for ${controller.selectedModel.value?.name ?? 'this model'}",
//             );
//           }

//           return GridView.builder(
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 0.6,
//               crossAxisSpacing: 8,
//               mainAxisSpacing: 8,
//             ),
//             itemCount: controller.products.length,
//             itemBuilder: (context, index) {
//               final product = controller.products[index];
//               return _buildProductCard(product);
//             },
//           );
//         }),
//       ],
//     );
//   }

//   // ==================== ALL PRODUCTS SECTION ====================

//   Widget _buildAllProductsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               "All Products",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             if (controller.isLoadingAllProducts.value)
//               const SizedBox(
//                 height: 16,
//                 width: 16,
//                 child: CircularProgressIndicator(strokeWidth: 2),
//               ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Obx(() {
//           if (controller.isLoadingAllProducts.value && controller.allProducts.isEmpty) {
//             return const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           }

//           if (controller.allProducts.isEmpty) {
//             return _buildEmptyState(
//               icon: Icons.inventory_2_outlined,
//               message: "No products available",
//               subMessage: "Check back later",
//             );
//           }

//           return GridView.builder(
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 0.6,
//               crossAxisSpacing: 8,
//               mainAxisSpacing: 8,
//             ),
//             itemCount: controller.allProducts.length > 4 ? 4 : controller.allProducts.length,
//             itemBuilder: (context, index) {
//               final product = controller.allProducts[index];
//               return _buildProductCard(product);
//             },
//           );
//         }),

//         if (controller.allProducts.length > 4)
//           Padding(
//             padding: const EdgeInsets.only(top: 8),
//             child: Center(
//               child: TextButton(
//                 onPressed: () {
//                   Get.snackbar('Info', 'View all products coming soon');
//                 },
//                 style: TextButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   minimumSize: Size.zero,
//                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 ),
//                 child: Text(
//                   'View All ${controller.allProducts.length} Products',
//                   style: TextStyle(fontSize: 12, color: Colors.teal.shade700),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   // ==================== PRODUCT CARD ====================

//   Widget _buildProductCard(ProductModel product) {
//     return GestureDetector(
//       onTap: () => controller.goToProductDetails(product),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey.shade200),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.shade100,
//               blurRadius: 2,
//               offset: const Offset(0, 1),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Product Image
//             Container(
//               height: 90,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade50,
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
//               ),
//               child: ClipRRect(
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
//                 child: product.image.isNotEmpty
//                     ? CachedNetworkImage(
//                         imageUrl: product.image,
//                         placeholder: (context, url) => const Center(
//                           child: SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           ),
//                         ),
//                         errorWidget: (context, url, error) => _buildNoImagePlaceholder(),
//                         fit: BoxFit.contain,
//                       )
//                     : _buildNoImagePlaceholder(),
//               ),
//             ),

//             // Product Details
//             Padding(
//               padding: const EdgeInsets.all(6),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Product Name
//                   Text(
//                     product.name,
//                     style: const TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),

//                   const SizedBox(height: 2),

//                   // Brand
//                   Text(
//                     controller.getBrandName(product.brandId),
//                     style: TextStyle(
//                       fontSize: 8,
//                       color: Colors.grey.shade600,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),

//                   const SizedBox(height: 4),

//                   // Price
//                   _buildPrice(product),

//                   const SizedBox(height: 4),

//                   // Add to Cart Button
//                   _buildAddToCartButton(product),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPrice(ProductModel product) {
//     if (product.hasDiscount) {
//       return Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 '₹${product.priceNum.toStringAsFixed(0)}',
//                 style: const TextStyle(
//                   fontSize: 9,
//                   decoration: TextDecoration.lineThrough,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(width: 4),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade100,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//                 child: Text(
//                   '${product.offerPercentage.toStringAsFixed(0)}%',
//                   style: TextStyle(
//                     fontSize: 7,
//                     color: Colors.green.shade800,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 1),
//           Text(
//             '₹${product.discountPriceNum.toStringAsFixed(0)}',
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//               color: Colors.green,
//             ),
//           ),
//         ],
//       );
//     }

//     return Text(
//       '₹${product.priceNum.toStringAsFixed(0)}',
//       style: const TextStyle(
//         fontSize: 12,
//         fontWeight: FontWeight.bold,
//         color: Colors.teal,
//       ),
//     );
//   }

//   Widget _buildAddToCartButton(ProductModel product) {
//     return SizedBox(
//       width: double.infinity,
//       height: 22,
//       child: ElevatedButton(
//         onPressed: () => controller.addToCart(product),
//         style: ElevatedButton.styleFrom(
//           padding: EdgeInsets.zero,
//           backgroundColor: Colors.teal,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//           elevation: 0,
//           minimumSize: const Size(0, 22),
//           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//         ),
//         child: const Text(
//           'Add',
//           style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
//         ),
//       ),
//     );
//   }

//   // ==================== HELPER WIDGETS ====================

//   Widget _buildInitialLoading() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CircularProgressIndicator(color: Colors.teal),
//           SizedBox(height: 12),
//           Text(
//             'Loading store...',
//             style: TextStyle(fontSize: 14, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState({
//     required IconData icon,
//     required String message,
//     String? subMessage,
//   }) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 40, color: Colors.grey.shade400),
//             const SizedBox(height: 6),
//             Text(
//               message,
//               style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//             ),
//             if (subMessage != null)
//               Text(
//                 subMessage,
//                 style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNoImagePlaceholder() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.image_not_supported,
//             size: 20,
//             color: Colors.grey.shade400,
//           ),
//           const SizedBox(height: 2),
//           Text(
//             'No Image',
//             style: TextStyle(color: Colors.grey.shade500, fontSize: 7),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBreadcrumb({required List<BreadcrumbItem> items}) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: items.asMap().entries.map((entry) {
//           final index = entry.key;
//           final item = entry.value;

//           return Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (item.onTap != null)
//                 GestureDetector(
//                   onTap: item.onTap,
//                   child: _buildBreadcrumbText(item.label, isLast: item.isLast),
//                 )
//               else
//                 _buildBreadcrumbText(item.label, isLast: item.isLast),

//               if (index < items.length - 1)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 2),
//                   child: Icon(
//                     Icons.chevron_right,
//                     size: 12,
//                     color: Colors.grey.shade500,
//                   ),
//                 ),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildBreadcrumbText(String label, {bool isLast = false}) {
//     return Text(
//       label,
//       style: TextStyle(
//         fontSize: 11,
//         fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
//         color: isLast ? Colors.teal : Colors.grey.shade700,
//         decoration: !isLast ? TextDecoration.underline : null,
//       ),
//     );
//   }
// }

// // Helper class for breadcrumb navigation
// class BreadcrumbItem {
//   final String label;
//   final VoidCallback? onTap;
//   final bool isLast;

//   BreadcrumbItem({required this.label, this.onTap, this.isLast = false});
// }