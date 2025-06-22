class Buku {
  final int id;
  final String judul;
  final String penulis;

  Buku({required this.id, required this.judul, required this.penulis});

  factory Buku.fromJson(Map<String, dynamic> json) {
    return Buku(id: json['id'], judul: json['judul'], penulis: json['penulis']);
  }
}
