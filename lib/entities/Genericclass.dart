// ignore_for_file: file_names
// Class chung để mô tả các đối tượng trong project (Câu 2)
class Genericclass<T> {
  T id;
  T name;
  T description;

  Genericclass({
    required this.id,
    required this.name,
    required this.description,
  });

  T getId() {
    return id;
  }

  T getName() {
    return name;
  }

  T getDescription() {
    return description;
  }

  T setId(T newId) {
    id = newId;
    return id;
  }

  T setName(T newName) {
    name = newName;
    return name;
  }

  T setDescription(T newDescription) {
    description = newDescription;
    return description;
  }

  @override
  String toString() {
    return '$runtimeType(id: $id, name: $name, description: $description)';
  }
}
