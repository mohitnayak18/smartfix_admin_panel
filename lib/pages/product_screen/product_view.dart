// screens/add_product_screen.dart
import 'dart:developer';
import 'dart:io';

import 'package:admin_panel/api_calls/models/brand_model.dart';
import 'package:admin_panel/api_calls/models/product_model.dart';
import 'package:admin_panel/api_calls/models/service.dart';
import 'package:admin_panel/pages/product_screen/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class AddProductScreen extends StatefulWidget {
  final ProductModel? productToEdit;
  
  const AddProductScreen({Key? key, this.productToEdit}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  
  final _formKey = GlobalKey<FormState>();
  final _productController = ProductController();
  
  // Form fields
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _discountPriceController;
  late TextEditingController _ratingController;
  
  // Selected values
  String? _selectedBrandId;
  String? _selectedModelId;
  String? _selectedServiceId;
  String? _imageUrl;
  XFile? _selectedImage;
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _models = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    
    _nameController = TextEditingController(text: widget.productToEdit?.name ?? '');
    _priceController = TextEditingController(text: widget.productToEdit?.price ?? '');
    _discountPriceController = TextEditingController(text: widget.productToEdit?.discountPrice ?? '');
    _ratingController = TextEditingController(text: widget.productToEdit?.rating ?? '');
    
    if (widget.productToEdit != null) {
      _selectedBrandId = widget.productToEdit!.brandId;
      _selectedModelId = widget.productToEdit!.modelId;
      _selectedServiceId = widget.productToEdit!.serviceId;
      _imageUrl = widget.productToEdit!.image;
    }
    
  }
  

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _productController.pickImage();
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _imageUrl = null; // Clear old URL when new image is selected
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedBrandId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a brand')),
      );
      return;
    }
    
    if (_selectedModelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a model')),
      );
      return;
    }
    
    if (_selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String finalImageUrl = _imageUrl ?? '';
      
      // Upload image if new image is selected
      if (_selectedImage != null) {
        finalImageUrl = (await _productController.uploadImage(_selectedImage!))!;
        log("Image URL: $finalImageUrl");
      }

      final product = ProductModel(
        id: widget.productToEdit?.id,
        brandId: _selectedBrandId!,
        modelId: _selectedModelId!,
        serviceId: _selectedServiceId!,
        name: _nameController.text,
        price: _priceController.text,
        discountPrice: _discountPriceController.text,
        rating: _ratingController.text,
        image: finalImageUrl,
      );
 
      // await _productController.saveProduct(product);
      try {
  await _productController.saveProduct(product);
  // print("✅ Product Saved");
} catch (e) {
  // print("❌ ERROR: $e");
}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(widget.productToEdit == null
              ? 'Product added successfully!'
              : 'Product updated successfully!',style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),),

          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,  
        ),
      );
      
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyActions: true,
        automaticallyImplyLeading: false,
        title: Text(widget.productToEdit == null ? 'Add Product' : 'Edit Product',style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker Section
              _buildImagePicker(),
              const SizedBox(height: 20),
              
              // Brand Dropdown
              _buildBrandDropdown(),
              const SizedBox(height: 16),
              
              // Model Dropdown (depends on brand)
              _buildModelDropdown(),
              const SizedBox(height: 16),
              
              // Service Dropdown
              _buildServiceDropdown(),
              const SizedBox(height: 16),
              
              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Price and Discount Price Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _discountPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Discount Price',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Rating
              TextFormField(
                controller: _ratingController,
                decoration: const InputDecoration(
                  labelText: 'Rating',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.star),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter rating';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.productToEdit == null 
                              ? 'Save Product' 
                              : 'Update Product',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
  return GestureDetector(
    onTap: _pickImage,
    child: Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _selectedImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(  // Changed from Image.file to Image.network
                _selectedImage!.path,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              ),
            )
          : _imageUrl != null && _imageUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  ),
                )
              : _buildImagePlaceholder(),
    ),
  );
}

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
        SizedBox(height: 8),
        Text(
          'Tap to select product image',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildBrandDropdown() {
    return StreamBuilder<List<BrandModel>>(
      stream: _productController.getBrands(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading brands');
        }
        
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final brands = snapshot.data!;
        
        return DropdownButtonFormField<String>(
         dropdownColor: Colors.white,
          value: _selectedBrandId,
          decoration: const InputDecoration(
            labelText: 'Select Brand',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.branding_watermark),
          ),
          items: brands.map((brand) {
            return DropdownMenuItem(
              value: brand.id,
              child: Text(brand.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedBrandId = value;
              _selectedModelId = null; // Reset model when brand changes
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a brand';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildModelDropdown() {
    if (_selectedBrandId == null) {
      return  DropdownButtonFormField<String>(
        dropdownColor: Colors.white,
        decoration: InputDecoration(
          labelText: 'Select Model',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.phone_android),
        ),
        items: [],
        onChanged: null,
        hint: Text('Select a brand first'),
      );
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _productController.getModelsByBrand(_selectedBrandId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading models');
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final models = snapshot.data!;
        
        return DropdownButtonFormField<String>(
          dropdownColor: Colors.white,
          value: _selectedModelId,
          decoration: const InputDecoration(
            labelText: 'Select Model',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone_android),
          ),
          items: models.map<DropdownMenuItem<String>>((model) {
            return DropdownMenuItem<String>(
              value: model['id'].toString(),
              child: Text(model['name'].toString()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedModelId = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a model';
            }
            return null;
          },
        );
      },
    );
  }

 Widget _buildServiceDropdown() {
  return StreamBuilder<List<ServiceModel>>(
    stream: _productController.getServices(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text('Error loading services: ${snapshot.error}');
      }

      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final services = snapshot.data!;
      
      if (services.isEmpty) {
        return const Text('No services available');
      }
      
      return DropdownButtonFormField<String>(
        dropdownColor: Colors.white,
        value: _selectedServiceId,
        decoration: const InputDecoration(
          labelText: 'Select Service',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.build),
        ),
        items: services.map((service) {
          return DropdownMenuItem(
            value: service.id,
            child: Text(service.name), // This should now show correctly
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedServiceId = value;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a service';
          }
          return null;
        },
      );
    },
  );
}
}