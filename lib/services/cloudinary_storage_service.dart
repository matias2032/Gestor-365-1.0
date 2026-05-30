// lib/services/cloudinary_storage_service.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CloudinaryStorageService {
  static final CloudinaryStorageService instance =
      CloudinaryStorageService._init();
  CloudinaryStorageService._init();

  // 🔑 Substitua pelos seus valores do Dashboard Cloudinary
  static String get _cloudName =>
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get _uploadPreset =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
  static const String _folder = 'produtos-imagens';

  bool get isConfigured =>
      _cloudName.isNotEmpty && _uploadPreset.isNotEmpty;

  String get _uploadUrl =>
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Faz upload de uma imagem e retorna a URL pública
  Future<String?> uploadImagem(String localPath) async {

      if (!isConfigured) {
    print('❌ Cloudinary não configurado. Verifique CLOUDINARY_CLOUD_NAME e CLOUDINARY_UPLOAD_PRESET no .env');
    return null;
  }
    try {
      final file = File(localPath);

      if (!await file.exists()) {
        print('❌ Arquivo não encontrado: $localPath');
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(localPath);
      final publicId = 'produto_$timestamp';

      print('📤 Iniciando upload: $publicId');

      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['public_id']     = '$_folder/$publicId';
      request.fields['folder']        = _folder;

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        localPath,
        contentType: MediaType.parse(_getContentType(extension)),
      ));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final publicUrl = json['secure_url'] as String;
        print('✅ Upload concluído: $publicUrl');
        return publicUrl;
      } else {
        print('❌ Cloudinary erro ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Erro inesperado ao fazer upload: $e');
      return null;
    }
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg': return 'image/jpeg';
      case '.png':  return 'image/png';
      case '.gif':  return 'image/gif';
      case '.webp': return 'image/webp';
      default:      return 'image/jpeg';
    }
  }

  Future<List<String>> uploadMultiplasImagens(List<String> localPaths) async {
    final urls = <String>[];
    for (final localPath in localPaths) {
      final url = await uploadImagem(localPath);
      if (url != null) {
        urls.add(url);
      } else {
        print('⚠️ Falha no upload de: $localPath');
      }
    }
    return urls;
  }

  /// Deleta imagem via API (requer assinatura — faça server-side se possível)
  Future<bool> deleteImagem(String publicUrl) async {
    try {
      // Extrai o public_id da URL Cloudinary
      // Ex: https://res.cloudinary.com/cloud/image/upload/v123/folder/nome.jpg
      final uri    = Uri.parse(publicUrl);
      final parts  = uri.pathSegments;
      // Remove extensão e pega tudo após "upload/vXXX/"
      final uploadIdx = parts.indexOf('upload');
      if (uploadIdx == -1) return false;

      // Ignora o segmento de versão (vXXX) se existir
      final afterUpload = parts.sublist(uploadIdx + 1);
      final versionless = afterUpload.first.startsWith('v') &&
              int.tryParse(afterUpload.first.substring(1)) != null
          ? afterUpload.sublist(1)
          : afterUpload;

      final publicId = versionless
          .join('/')
          .replaceAll(RegExp(r'\.[^.]+$'), ''); // remove extensão

      print('🗑️ Deletando: $publicId');

      // ⚠️ Deletar imagens requer API_SECRET — implemente num backend/edge function
      // Aqui apenas logamos; implemente conforme a sua arquitectura de segurança
      print('⚠️ Delete requer API_SECRET — implemente no backend');
      return false;

    } catch (e) {
      print('❌ Erro ao deletar imagem: $e');
      return false;
    }
  }

  bool isCloudinaryUrl(String caminho) {
    return caminho.startsWith('http') && caminho.contains('cloudinary');
  }

  // Mantém compatibilidade com código existente que chamava isSupabaseUrl
  bool isRemoteUrl(String caminho) {
    return isCloudinaryUrl(caminho) || 
           (caminho.startsWith('http') && caminho.contains('supabase'));
  }

  /// Cache local permanente (mesmo comportamento do serviço anterior)
  Future<String?> cacheImagemLocal(String publicUrl) async {
    try {
      if (!isRemoteUrl(publicUrl)) {
        return publicUrl; // já é local
      }

      // Usa o último segmento da URL como nome de ficheiro
      final uri      = Uri.parse(publicUrl);
      final fileName = uri.pathSegments.last;

      final directory  = await getApplicationDocumentsDirectory();
      final imagensDir = Directory('${directory.path}/produto_imagens');

      if (!await imagensDir.exists()) {
        await imagensDir.create(recursive: true);
      }

      final localPath = '${imagensDir.path}/$fileName';
      final localFile = File(localPath);

      if (await localFile.exists()) {
        print('✅ Imagem já existe localmente: $localPath');
        return localPath;
      }

      print('📥 Baixando imagem: $fileName');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        await localFile.writeAsBytes(response.bodyBytes);
        print('✅ Imagem baixada e salva: $localPath');
        return localPath;
      } else {
        print('❌ Falha ao baixar imagem: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Erro ao cachear/salvar imagem: $e');
      return null;
    }
  }
}