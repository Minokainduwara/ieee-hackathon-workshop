type Post readonly & record  {|
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
