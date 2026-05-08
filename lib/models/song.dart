class Song {
  final String title;
  final String artist;
  final String url;
  final String coverUrl;

  Song({
    required this.title,
    required this.artist,
    required this.url,
    required this.coverUrl,
  });
}

// Danh sách 10 bài nhạc online lấy từ GitHub Raw
List<Song> myPlaylist = [
  Song(
    title: "Nàng Thơ",
    artist: "Hoàng Dũng",
    url:
        "https://raw.githubusercontent.com/nguyenminhcong04/Lan6_ung_dung_nghe_nhac_online/main/songs/nang_tho.mp3",
    coverUrl: "https://picsum.photos/400/400?sig=1",
  ),
  Song(
    title: "Lạc Trôi",
    artist: "Sơn Tùng M-TP",
    url:
        "https://raw.githubusercontent.com/nguyenminhcong04/Lan6_ung_dung_nghe_nhac_online/main/songs/lac_troi.mp3",
    coverUrl: "https://picsum.photos/400/400?sig=2",
  ),
  Song(
    title: "Waiting For Love",
    artist: "Avicii",
    url:
        "https://raw.githubusercontent.com/nguyenminhcong04/Lan6_ung_dung_nghe_nhac_online/main/songs/Waiting_For_Love.mp3",
    coverUrl: "https://picsum.photos/400/400?sig=3",
  ),
  Song(
    title: "Waiting For You",
    artist: "MONO",
    url:
        "https://raw.githubusercontent.com/nguyenminhcong04/Lan6_ung_dung_nghe_nhac_online/main/songs/Waiting_For_You.mp3",
    coverUrl: "https://picsum.photos/400/400?sig=4",
  ),
  Song(
    title: "Âm Thầm Bên Em",
    artist: "Sơn Tùng M-TP",
    url:
        "https://raw.githubusercontent.com/nguyenminhcong04/Lan6_ung_dung_nghe_nhac_online/main/songs/am_tham_ben_em.mp3",
    coverUrl: "https://picsum.photos/400/400?sig=5",
  ),
  Song(
    title: "Có Chắc Yêu Là Đây",
    artist: "Sơn Tùng M-TP",
    url:
        "https://raw.githubusercontent.com/nguyenminhcong04/Lan6_ung_dung_nghe_nhac_online/main/songs/co_chac_yeu_la_day.mp3",
    coverUrl: "https://picsum.photos/400/400?sig=6",
  ),
  Song(
    title: "Gác Lại Âu Lo",
    artist: "Da LAB ft. Miu Lê",
    url:
        "https://raw.githubusercontent.com/nguyenminhcong04/Lan6_ung_dung_nghe_nhac_online/main/songs/gac_lai_au_lo.mp3",
    coverUrl: "https://picsum.photos/400/400?sig=7",
  ),
  Song(
    title: "Một Bước Yêu Vạn Dặm Đau",
    artist: "Mr. Siro",
    url:
        "https://raw.githubusercontent.com/nguyenminhcong04/Lan6_ung_dung_nghe_nhac_online/main/songs/mot_buoc_yeu_van_dam_dau.mp3",
    coverUrl: "https://picsum.photos/400/400?sig=8",
  ),
  Song(
    title: "3107",
    artist: "W/N",
    url:
        "https://raw.githubusercontent.com/nguyenminhcong04/Lan6_ung_dung_nghe_nhac_online/main/songs/3107.mp3",
    coverUrl: "https://picsum.photos/400/400?sig=9",
  ),
  Song(
    title: "Phía Sau Một Cô Gái",
    artist: "Soobin Hoàng Sơn",
    url:
        "https://raw.githubusercontent.com/nguyenminhcong04/Lan6_ung_dung_nghe_nhac_online/main/songs/phia_sau_mot_co_gai.mp3",
    coverUrl: "https://picsum.photos/400/400?sig=10",
  ),
];
