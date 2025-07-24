import ballerina/http;

table<Post> key(id) PostTable = table[];

service /api on new http:Listener(9090) {
    
}

