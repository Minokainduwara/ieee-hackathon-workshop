import ballerina/http;

type Post readonly & record {|
    readonly int id;
    int userId;
    string description;
    string tags;
    string category;
|};

type NewPost record {|
    int userId;
    string description;
    string tags;
    string category;
|};

type PostCreated record {|
    *http:Created;
    Post body;
|};

type Meta record {|
    string[] tags;
    string category;
|};

type PostWithMeta record {|
    int id;
    int userId;
    string description;
    Meta meta;
|};

function transformPost(Post post) returns PostWithMeta => {
    id: post.id,
    userId: post.userId,
    description: post.description,
    meta: {
        category: post.category,
        tags: re `,`.split(post.tags)
    }

};
