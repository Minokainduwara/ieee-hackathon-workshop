import ballerina/http;
import ballerina/sql;

type Post readonly & record {|
    @sql:Column {name: "id"}
    readonly int id;
    @sql:Column {name: "userId"}
    int userId;
    @sql:Column {name: "description"}
    string description;
    @sql:Column {name: "tags"}
    string tags;
    @sql:Column {name: "category"}
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


type Probability record {|
    decimal neg;
    decimal neutral;
    decimal pos;
|};

type Sentiment record {|
    string label;
    Probability probability;
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
