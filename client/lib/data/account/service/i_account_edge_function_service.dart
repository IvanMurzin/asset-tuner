abstract interface class IAccountEdgeFunctionService {
  Future<void> deleteAccountCascade({
    required String userId,
    required String accountId,
  });
}
