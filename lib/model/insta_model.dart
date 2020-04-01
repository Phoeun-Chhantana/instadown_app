class InstaModel{
  final String country_code;
  final String platform;
  final Config config;
  final EntryData entryData;

  InstaModel({this.country_code, this.platform, this.config, this.entryData});

  factory InstaModel.fromJson(Map<String, dynamic> json){
    return InstaModel(
      country_code: json['country_code'],
      platform: json['platform'],
      entryData: EntryData.fromJson(json['entry_data'])
    );
  }
}

class Config{
  final String csrf_token;

  Config({this.csrf_token});

  factory Config.fromJson(Map<String, dynamic> json){
    return Config(
      csrf_token: json['csrf_token'],
    );
  }
}

class EntryData{
  List<PostPage> postPages;
  EntryData({this.postPages});
  
  EntryData.fromJson(Map<String, dynamic> json){
    if(json['PostPage'] != null){
      postPages = new List<PostPage>();
      json['PostPage'].forEach((v){
        postPages.add(PostPage.fromJson(v));
      });
    }
  }
}

class PostPage{
  final Graphql graphql;
  
  PostPage({this.graphql});

  factory PostPage.fromJson(Map<String, dynamic> json){
    return PostPage(
      graphql: Graphql.fromJson(json['graphql'])
    );
  }
}

class Graphql{
  ShortCodeMedia shortCodeMedia;
  Graphql({this.shortCodeMedia});

  factory Graphql.fromJson(Map<String, dynamic> json){
    return Graphql(
      shortCodeMedia: ShortCodeMedia.fromJson(json['shortcode_media'])
    );
  }
}

class ShortCodeMedia{
  final String display_url;
  final EdgeSidecarToChildren sidecarToChildren;
  ShortCodeMedia({this.display_url, this.sidecarToChildren});

  factory ShortCodeMedia.fromJson(Map<String, dynamic> json){
    return ShortCodeMedia(
      display_url: json['display_url'],
      sidecarToChildren: EdgeSidecarToChildren.fromJson(json['edge_sidecar_to_children'])
    );
  }
}

class EdgeSidecarToChildren{
  List<Edges> edges;

  EdgeSidecarToChildren.fromJson(Map<String, dynamic> json){
    if(json['edges'] != null){
      edges = new List<Edges>();
      json['edges'].forEach((v){
        edges.add(Edges.fromJson(v));
      });
    }
  }
}

class Edges{
  final Node node;
  Edges({this.node});
  
  factory Edges.fromJson(Map<String, dynamic> json){
    return Edges(
      node: Node.fromJson(json['node'])
    );
  }
}

class Node{
  String display_url;
  List<DisplayResource> resources;

  Node.fromJson(Map<String, dynamic> json){
    display_url = json['display_url'];
    if(json['display_resources'] != null){
      resources = new List<DisplayResource>();
      json['display_resources'].forEach((v){
        resources.add(DisplayResource.fromJson(v));
      });
    }
  }
}

class DisplayResource{
  final String src;
  DisplayResource({this.src});

  factory DisplayResource.fromJson(Map<String, dynamic> json){
    return DisplayResource(
      src: json['src']
    );
  }
}

class Owner{
  final bool is_private;
  Owner({this.is_private});

  factory Owner.fromJson(Map<String, dynamic> json){
    return Owner(
      is_private: json['is_private']
    );
  }
}
