import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:oidc_core/oidc_core.dart';

import 'package:oidc_platform_interface/oidc_platform_interface.dart';

/// The iOS implementation of [OidcPlatform].
class OidcIOS extends OidcPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('oidc_ios');

  /// Registers this class as the default instance of [OidcPlatform]
  static void registerWith() {
    OidcPlatform.instance = OidcIOS();
  }

  @override
  Future<OidcAuthorizeResponse?> getAuthorizationResponse(
    OidcProviderMetadata metadata,
    OidcAuthorizeRequest request,
    OidcStore store,
    OidcAuthorizeState? stateData,
    OidcAuthorizePlatformSpecificOptions options,
  ) async {
    const appAuth = FlutterAppAuth();
    final authorizationEndpoint = metadata.authorizationEndpoint;
    final tokenEndpoint = metadata.tokenEndpoint;
    if (authorizationEndpoint == null || tokenEndpoint == null) {
      throw const OidcException(
        'OIDC provider MUST declare an '
        'authorization endpoint and a token endpoint',
      );
    }
    final resp = await appAuth.authorize(
      AuthorizationRequest(
        request.clientId,
        request.redirectUri.toString(),
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint: authorizationEndpoint.toString(),
          tokenEndpoint: tokenEndpoint.toString(),
          endSessionEndpoint: metadata.endSessionEndpoint?.toString(),
        ),
        additionalParameters:
            request.extra.map((key, value) => MapEntry(key, value.toString())),
        issuer: metadata.issuer?.toString(),
        loginHint: request.loginHint,
        nonce: request.nonce,
        promptValues: request.prompt,
        scopes: request.scope,
        responseMode: request.responseMode,
        allowInsecureConnections: options.ios.allowInsecureConnections,
        preferEphemeralSession: options.ios.preferEphemeralSession,
      ),
    );
    if (resp == null) {
      return null;
    }
    return OidcAuthorizeResponse.fromJson({
      OidcConstants_AuthParameters.code: resp.authorizationCode,
      OidcConstants_AuthParameters.codeVerifier: resp.codeVerifier,
      OidcConstants_AuthParameters.nonce: resp.nonce,
      OidcConstants_AuthParameters.redirectUri: request.redirectUri,
      // add state here since appauth handles state itself
      OidcConstants_AuthParameters.state: request.state,
      ...?resp.authorizationAdditionalParameters,
    });
  }

  // @override
  // Future<String?> getPlatformName() {
  //   return methodChannel.invokeMethod<String>('getPlatformName');
  // }
}
