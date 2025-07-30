import ballerina/http;
import ballerina/sql;
import ballerinax/java.jdbc;

table<Post> key(id) PostTable = table [
    {
        id: 1,
        userId: 1,
        description: "Exploring Ballerina Language",
        tags: "ballerina, programming, language",
        category: "Technology"
    },
    {
        id: 2,
        userId: 2,
        description: "Introduction to Microservices",
        tags: "microservices, architecture, introduction",
        category: "Software Engineering"
    }
];

function initDatabase(sql:Client sqlClient) returns error? {
    _ = check sqlClient->execute(`CREATE TABLE IF NOT EXISTS posts (id INT PRIMARY KEY, userId INT, description VARCHAR(255), tags VARCHAR(255), category VARCHAR(50))`);
}



service /api on new http:Listener(9090) {

    //Define sentiment api
    http:Client sentimentClient;
    sql:Client dbClient;

    function init() returns error? {
        self.sentimentClient = check new ("http://localhost:9090/sentiment");
        self.dbClient = check new jdbc:Client("jdbc:h2:./databases/SOCIAL_MEDIA");
        check initDatabase(self.dbClient);
    }

    //we pass category as a query parameter. it can be a string or null value
      resource function get posts(string? category) returns boolean|Post[]|table<Post> key<int>|sql:Error {
        stream<Post, sql:Error?> postStream = self.dbClient->query(`SELECT * FROM posts`);
        table<Post> postTable = check from Post post in postStream select post;
        return postTable.toArray();
        //check category is a string value

    }

    resource function get posts/[int id]() returns Post|http:NotFound|sql:Error {
        Post post = check self.dbClient->queryRow(`SELECT * FROM posts WHERE id = ?`, id);
        //check if the post with the given id exists
        return post is Post? post : http:NOT_FOUND;
    }

    resource function post posts(NewPost newPost) returns PostCreated|http:BadRequest|error {
        do {
            json sentiment = check self.sentimentClient->/sentiment.post({text: newPost.description});

            if sentiment.label == "neg" {
                return http:BAD_REQUEST;
            }
            int id = PostTable.nextKey();
            Post post = {
                id,
                ...newPost
            };
            PostTable.add(post);
            return <PostCreated>{
                body: post
            };
        } on fail error err {
            if err is http:PayloadBindingError {
                return http:BAD_REQUEST;
            } else {
                return err;
            }
        }

    }

    resource function delete posts/[int id]() returns http:NoContent|http:NotFound {
        //check if the post with the given id exists
        if PostTable.hasKey(id) {
            _ = PostTable.remove(id);
            return http:NO_CONTENT;
        }
        return http:NOT_FOUND;

    }

    resource function get post/[int id]/meta() returns PostWithMeta|http:NotFound {
        //check if the post with the given id exists
        if PostTable.hasKey(id) {
            Post post = PostTable.get(id);
            return transformPost(post);
        }
        return http:NOT_FOUND;

    }

}

