import ballerina/http;

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

service /api on new http:Listener(9090) {

    //we pass category as a query parameter. it can be a string or null value
    resource function get posts(string? category) returns boolean|Post[]|table<Post> key<int> {
        //check category is a string value
        if category is string {
            //filter posts by category
            table<Post> key<int> filteredPosts = PostTable.filter(function(Post post) returns boolean {
                return post.category == category;
            });
            return filteredPosts;
        }
        return PostTable.toArray();
        
    }

    resource function get Posts/[int id]() returns Post|http:NotFound{
        //check if the post with the given id exists
        return PostTable.hasKey(id)? PostTable.get(id) : http:NOT_FOUND;
    }



}

