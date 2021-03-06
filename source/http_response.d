import std.stdio;
import core.stdc.string : strlen;
import std.conv : to;
import std.string;
import std.path;
import std.file;

class HTTPResponse {
  private:
  string method_;
  string[string] header_;
  ubyte[] data_;

  public:
  this(string method="GET") {
    method_ = method;
  }

  @property
  {
    ubyte[] data() { return data_; }
  }

  void setHeader(string key, string value) {
    header_[key] = value;
  }

  int calcContentLength() {
    return cast(int)(data_.length);
  }

  string generateHeader() {
    header_["Content-Length"] = to!string(calcContentLength());
    string header = "";
    foreach (key; header_.keys()) {
      header ~= (key ~ ": " ~ header_[key]);
      header ~= "\r\n";
    }
    return header;
  }

  string generateStatusLine(int code) {
    string[int] table = [
      200: "OK",
      400: "Bad Request",
      404: "Not Found",
      405: "Method Not Allowed",
      500: "Internal Server Error"
    ];
    return "HTTP/1.0 " ~ to!string(code) ~ " " ~ to!string(table[code]) ~ "\r\n";
  }

  void deleteHeader(string key) {
    header_.remove(key);
  }

  void setBody(ubyte[] data) {
    data_ = data;
  }

  string getContentType(string filepath) {
    string ext = toLower(extension(filepath));
    // TODO: Fix it
    string[string] contentTypes = [
      ".html": "text/html; charset=utf-8",
      ".css": "text/css",
      ".png": "image/png",
      ".gif": "image/gif",
      ".jpeg": "image/jpeg",
      ".jpg": "image/jpeg",
      ".js": "text/javascript"
    ];
    // default content type is text/plain
    return contentTypes.get(ext, "text/plain");
  }

  void setBodyFromPath(string filepath) {
    string contentType = getContentType(filepath);
    setHeader("Content-Type", contentType);
    setBody(cast(ubyte[])read(filepath));
  }

  string generateData(int code) {
    string res = "";
    res ~= generateStatusLine(code);
    res ~= generateHeader();
    res ~= "\r\n";
    if (method_ == "HEAD") {
      return res;
    }
    res ~= cast(string)data_;
    return res;
  }

}
