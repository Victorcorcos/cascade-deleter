<p align="center">
  <img src="https://i.imgur.com/wUx1CYi.png" alt="Cascade Delete" width="200" height="200"/>
</p>

<p align="center">
Cascade Deleter is a ruby gem designed to delete a set of items with all of their children, grandchildren, grandgrandchildren.
I.e. delete items and all of their descending hierarchy.
</p>


## Why it is necessary? 💡

Currently, **Rails** doesn't have a builtin way to delete items with all of their descending hierarchy, this type of deletion requires manual and tedious work, since you need to discover which items should be deleted for each descending classes, one by one.

**Well, `CascadeDeleter` solves this issue perfectly with a oneliner command 🏆**


## Example 🧑‍🏫

As an illustrative example, let's think about the following classes structure:

1. Class `Person` has_many books
2. Class `Book` has_many pages
3. Class `Page` has_many words
4. Class `Word`

That means: `Person` is parent of a list of `Book`s, which is parent of a list of `Page`s, which is parent of a list of `Word`s.

Now, imagine that you want to delete people with `id = 1`, `id = 2` and `id = 3` of the following hierarchy:

#### Hierarchy

<p align="center">
  <img src="https://i.imgur.com/90LZXUj.png" alt="Hierarchy"/>
</p>

The correct solution would be to to delete it from the leaves to the root, which means deleting the items on this order:

1. Delete the `words` that belongs to these `people` through the `word` → `page` → `book` → `people` relationship.
1.1. Delete: `Word A`, `Word B`, `Word C`, `Word D`, `Word E`, `Word F`, `Word G`, `Word H`, `Word I`.

2. Delete the `pages` that belongs to these `people` through the `page` → `book` → `people` relationship.
2.1. Delete: `Page A`, `Page B`, `Page C`, `Page D`, `Page E`, `Page F`, `Page G`.

3. Delete the `books` that belongs to these `people` through the `book` → `people` relationship.
3.1. Delete: `Book 1`, `Book 2`, `Book 3`, `Book 4`.

4. Finally deleting the `people`
4.1. Delete: `Person 1`, `Person 2`, `Person 3`.

With the `cascade-deleter` gem, **these deletions will be done automatically**.

```rb
CascadeDeleter.new(Person.where(id: [1, 2, 3]).delete_all
# "Person.where(id: [1, 2, 3])" is used for this example, but you can place any ActiveRecord Relation as an argument here!
```

#### Deletions Order

① → ② → ③ → 🚩

<p align="center">
  <img src="https://i.imgur.com/uaf1R02.png" alt="Deletion Order"/>
</p>


## Installation ⚙️

Add `cascade-deleter` to your Gemfile.

```rb
gem 'cascade-deleter'
```


## Usage 🚀

Just require the `cascade_deleter` library and use it! (You can test this on `rails console`)

* Usage ①: **Hard** Delete of inactive Projects
```rb
CascadeDeleter.new(Project.unscoped.where(active: false)).delete_all
```

* Usage ②: **Hard** Delete of inactive Projects overriding the `joins` parameter.
You can override the `joins` parameter through the `custom_joins` attribute if you want more accurate relationships
*in case the `joins` is not provided (**Usage ①**), the shortest path between each children class and the root class will be chosen for each join*

```rb
CascadeDeleter.new(Project.unscoped.where(active: false)).delete_all(
  custom_joins: {
    'Attachment' => {:subproject=>:project}
  }
)
```

⤷ That means: When deleting the `Attachment` descending class of `Project`, the following statement will be executed:

```rb
Attachment.joins({:subproject=>:project}).where(projects: { active: false }).delete_all
```

* Usage ③: **Soft** Delete of *TO BE DELETED* Disciplines
```rb
CascadeDeleter.new(Discipline.where(description: '[TO BE DELETED]')).delete_all(
  method: :soft
)
```

⚠️ When using **Soft** deletion (`method: :soft`), be aware that the `active` *boolean* parameter of your database tables will be used, so you need to have the `active` *boolean* parameter in your database tables when using **Soft** deletion.

```rb
t.boolean "active", default: true
```


## Contact

* [Victor Cordeiro Costa](https://www.linkedin.com/in/victor-costa-0bba7197/)

---

*This repository is maintained and developed by [Victor Cordeiro Costa](https://www.linkedin.com/in/victor-costa-0bba7197/). For inquiries, partnerships, or support, don't hesitate to get in touch.
