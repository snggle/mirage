enum RequestType {
  empty,
  enumerate,
  listen,
  acquire,
  release,
  call,
  notFound;

  factory RequestType.getRequestTypeFromString(String type) {
    switch (type) {
      case 'enumerate':
        return RequestType.enumerate;
      case 'listen':
        return RequestType.listen;
      case 'acquire':
        return RequestType.acquire;
      case 'release':
        return RequestType.release;
      case 'call':
        return RequestType.call;
      default:
        return RequestType.notFound;
    }
  }
}

