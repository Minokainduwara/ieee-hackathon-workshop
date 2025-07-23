import ballerina/http;

// in-memory Ballerina table to store the posts
table<Post> key{id}
service /api on new http:Listener(9090) {
    
}
