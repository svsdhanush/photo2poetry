class PoemResponse {
  final String poem;
  final int? remainingRequests;
  final int? resetAt;

  PoemResponse({required this.poem, this.remainingRequests, this.resetAt});

  @override
  String toString() =>
      'PoemResponse(poemLength: ${poem.length}, remaining: $remainingRequests, resetAt: $resetAt)';
}
