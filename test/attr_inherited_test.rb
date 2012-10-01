require 'test_helper'

class AttributeChoicesTest < ActiveSupport::TestCase

  class Post < ActiveRecord::Base
    has_many :comments, as: :commentable
  end

  class Version < ActiveRecord::Base
    belongs_to  :post
    has_many :comments, as: :commentable

    attr_inherited :title, :body, from: :post
    attr_inherited :synopsis, from: :post, as: :description

    attr_inherited :comments, from: :post, when: :empty?
  end

  class Comment < ActiveRecord::Base
    belongs_to :commentable, polymorphic: true
  end

  test "It should add a class method to all ActiveRecord objects" do
    assert_respond_to ActiveRecord::Base, :attr_inherited
    assert_respond_to Post, :attr_inherited
    assert_respond_to Version, :attr_inherited
    assert_respond_to Comment, :attr_inherited
  end

  test "It does not inherit attributes if its parent object is nil" do
    version = Version.create! author: "Christos Zisopoulos", title: "First post"

    assert_equal version.title, "First post"
    assert_equal version.body, nil
    assert_equal version.author, "Christos Zisopoulos"
  end

  test "It inherits attributes from the specified parent association when attribute is nil" do
    post = Post.create! title: "First post", body: "First post body"
    version = Version.create! author: "Christos Zisopoulos", post: post

    assert_equal version.title, "First post"
    assert_equal version.body, "First post body"
    assert_equal version.author, "Christos Zisopoulos"
  end

  test "Inherited attribute's name can be aliased" do
    post = Post.create! synopsis: "First post synopsis"
    version = Version.create! post_id: post.id

    assert_equal version.description, "First post synopsis"
  end

  test "Overrding the values of inherited attributes" do
    post = Post.create! title: "First post", body: "First post body"
    version = Version.create! do |v|
      v.post_id = post.id
      v.title = "Version title"
      v.body =  "Version body"
      v.description =  "Version description"
      v.author = "Christos Zisopoulos"
    end

    assert_equal version.title, "Version title"
    assert_equal version.body, "Version body"
    assert_equal version.description, "Version description"
    assert_equal version.author, "Christos Zisopoulos"
  end

  test "Using a user defined predicate to decide when to inherit" do
    post = Post.create! title: "First post", body: "First post body"
    post.comments.create! body: "Comment 1"
    version = Version.create! post_id: post.id

    assert_equal version.comments, post.comments

    version_comment = Comment.create! body: "Comment 3"
    version.comments = [version_comment]

    assert_equal version.comments, [version_comment]
  end

end

