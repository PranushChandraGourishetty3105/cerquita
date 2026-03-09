class CategoryCard extends StatelessWidget {

final String title;

const CategoryCard({super.key, required this.title});

@override
Widget build(BuildContext context) {

return Container(
width: 90,
margin: EdgeInsets.only(right:10),
padding: EdgeInsets.all(10),
decoration: BoxDecoration(
color: Colors.blue.shade100,
borderRadius: BorderRadius.circular(15),
),

child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [

Icon(Icons.category),

SizedBox(height:5),

Text(title,textAlign:TextAlign.center),

],
),
);

}
}