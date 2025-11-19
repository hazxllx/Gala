import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  static Future<List<String>> uploadEstablishmentImages(List<File> images) async {
    List<String> uploadedUrls = [];

    try {
      for (int i = 0; i < images.length; i++) {
        File imageFile = images[i];
        
        // Generate unique filename
        String fileName = 'establishment_${DateTime.now().millisecondsSinceEpoch}_$i${path.extension(imageFile.path)}';
        
        // Create reference to Firebase Storage
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('establishments/$fileName');
        
        // Set metadata
        SettableMetadata metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploaded_at': DateTime.now().toIso8601String(),
          },
        );
        
        print('Uploading image ${i + 1}/${images.length}: $fileName');
        
        // Upload file
        UploadTask uploadTask = storageRef.putFile(imageFile, metadata);
        
        // Wait for completion
        TaskSnapshot snapshot = await uploadTask;
        
        // Get download URL
        String downloadUrl = await snapshot.ref.getDownloadURL();
        uploadedUrls.add(downloadUrl);
        
        print('Successfully uploaded ${i + 1}/${images.length}');
      }
      
      return uploadedUrls;
      
    } on FirebaseException catch (e) {
      print('Firebase Storage Error: ${e.code} - ${e.message}');
      throw Exception('Upload failed: ${e.message}');
    } catch (e) {
      print('Upload Error: $e');
      throw Exception('Failed to upload images: $e');
    }
  }
}
