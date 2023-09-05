import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:oidc_core/oidc_core.dart';

@internal
class OidcInternalUtilities {
  static Future<http.Response> sendWithClient({
    required http.Client? client,
    required http.Request request,
  }) async {
    //
    final shouldDispose = client == null;
    client ??= http.Client();
    try {
      final res = await client.send(request).then(http.Response.fromStream);
      return res;
    } finally {
      if (shouldDispose) {
        client.close();
      }
    }
  }
}

/// Utilities for the Oidc spec
class OidcUtils {
  /// Takes a base Url and adds /.well-known/openid-configuration to it
  static Uri getWellKnownUriFromBase(Uri base) {
    return base.replace(
      pathSegments: [
        ...base.pathSegments,
        '.well-known',
        'openid-configuration',
      ],
    );
  }

  /// Gets the Oidc provider metadata from a '.well-known' url
  static Future<OidcProviderMetadata> getProviderMetadata(
    Uri wellKnownUri, {
    Map<String, String>? headers,
    http.Client? client,
  }) async {
    final req = http.Request(OidcConstants_RequestMethod.get, wellKnownUri);
    if (headers != null) {
      req.headers.addAll(headers);
    }
    final resp = await OidcInternalUtilities.sendWithClient(
      client: client,
      request: req,
    );
    if (resp.statusCode != 200) {
      throw OidcException(
        'Server responded with a non-200 statusCode',
        extra: {
          OidcConstants_Exception.request: req,
          OidcConstants_Exception.response: resp,
          OidcConstants_Exception.statusCode: resp.statusCode,
        },
      );
    }
    final decoded = jsonDecode(resp.body);
    return OidcProviderMetadata.fromJson(decoded as Map<String, dynamic>);
  }
}