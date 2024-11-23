import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'components/workwithform.dart';
import 'l10n/app_localizations.dart';
import 'main.dart';
import 'model/teamsubjobmodel.dart';
import 'model/theme.dart';
import 'model/usermodel.dart';

class CoopSubDetailPage extends StatefulWidget {
  final Teamsubjobmodel teamsubjobmodel;
  final String loginuserid;
  final List<User> allParticipants;

  const CoopSubDetailPage(
      {super.key,
      required this.teamsubjobmodel,
      required this.loginuserid,
      required this.allParticipants});
  @override
  CoopSubDetailPageState createState() => CoopSubDetailPageState();
}

class CoopSubDetailPageState extends State<CoopSubDetailPage> {
  List<String> workByUserIds = [];
  late List<User> participatingUsers;
  List<String> workByUserIdsToSend = [];
  List<String> selectedUserIds = [];
  late String linkWorkArea;
  late String linkSubmitWork;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController linkWorkAreaController = TextEditingController();
  final TextEditingController linkSubmitWorkController =
      TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  DateTime? startDate; // Changed to nullable
  DateTime? lastDate; // Changed to nullable
  TimeOfDay? startTime; // Changed to nullable
  TimeOfDay? lastTime; // Changed to nullable
  late Future<List<Teamsubjobmodel>> futureTasks;
  late String headSubJobId;

  @override
  void initState() {
    super.initState();
    futureTasks =
        fetchTeamSubTasks(); // เรียกใช้ฟังก์ชันนี้ครั้งเดียวใน initState
    participatingUsers = [];
    fetchParticipatingUsers(participatingUsers);
  }

  Future<void> fetchParticipatingUsers(List<User> participatingUsers) async {
    for (String userId in widget.teamsubjobmodel.workByUserID) {
      User? user = await fetchUserById(userId, context);
      if (user != null) {
        participatingUsers.add(user);
        workByUserIds.add(userId);
        workByUserIdsToSend.add(userId);
      }
    }
    setState(() {});
  }

  void toggleUserSelection(String userId) {
    setState(() {
      if (selectedUserIds.contains(userId)) {
        selectedUserIds.remove(userId);
      } else {
        selectedUserIds.add(userId);
      }
      workByUserIds = selectedUserIds; // Update the selected user list
    });
  }

  Future<List<Teamsubjobmodel>> fetchTeamSubTasks() async {
    final Dio dio = Dio();
    final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
    final String url = '$apiUrl/v1/teamSubJob/subjob/${widget.loginuserid}';
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> taskListJson = response.data;
      return taskListJson
          .map((json) => Teamsubjobmodel.fromJson(json))
          .where((task) =>
              task.jobId == widget.teamsubjobmodel.jobId) // กรอง jobId
          .toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Scaffold(
      backgroundColor: pastel.pastel2,
      appBar: AppBar(
        backgroundColor: pastel.pastel1,
        title: Text(
          overflow: TextOverflow.ellipsis,
          AppLocalizations.of(context).translate('coop'),
          style:
              TextStyle(color: pastel.pastelFont, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: pastel.pastelFont),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DefaultTabController(
          length: 2, // จำนวนแท็บ
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    overflow: TextOverflow.ellipsis,
                    widget.teamsubjobmodel.name,
                    style: TextStyle(
                        fontSize: screenWidth * 0.09,
                        fontWeight: FontWeight.bold,
                        color: pastel.pastelFont),
                  ),
                  IconButton(
                    icon: const Icon(Icons.block_sharp),
                    onPressed: () {
                      showDeleteConfirmationDialog(context, 'teamSubJob',
                          widget.teamsubjobmodel.subJobId);
                    },
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.014),
              Text(
                overflow: TextOverflow.ellipsis,
                '${AppLocalizations.of(context).translate('date')} : ${widget.teamsubjobmodel.startDate.day.toString()}/${widget.teamsubjobmodel.startDate.month.toString()}/${widget.teamsubjobmodel.startDate.year.toString()} - ${widget.teamsubjobmodel.lastDate.day.toString()}/${widget.teamsubjobmodel.lastDate.month.toString()}/${widget.teamsubjobmodel.lastDate.year.toString()}',
                style: TextStyle(
                    fontSize: screenWidth * 0.06, color: pastel.pastelFont),
              ),
              SizedBox(height: screenHeight * 0.014),
              Text(
                overflow: TextOverflow.ellipsis,
                '${AppLocalizations.of(context).translate('participants')} :',
                style: TextStyle(
                    fontSize: screenWidth * 0.06, color: pastel.pastelFont),
              ),
              Row(
                children: [
                  Row(
                    children: participatingUsers.map((user) {
                      return Container(
                        width: screenWidth * 0.09,
                        height: screenWidth * 0.09,
                        margin: EdgeInsets.only(left: screenWidth * 0.03),
                        decoration: BoxDecoration(
                          color: pastel.pastelProgress,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '',
                            style: TextStyle(
                              color: pastel.participant,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.06,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SelectParticipantsWidget(
                            teamsubJobmodel: widget.teamsubjobmodel,
                            participatingUsers: widget.allParticipants,
                            selectedUserIds: selectedUserIds,
                            onToggleUserSelection: toggleUserSelection,
                            pastel: pastel,
                            context: context,
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: pastel.pastelProgress,
                      foregroundColor: pastel.participant,
                    ),
                    child: Icon(Icons.add, color: pastel.participant),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.014),
              Text(
                overflow: TextOverflow.ellipsis,
                "${AppLocalizations.of(context).translate('details')} :",
                style: TextStyle(
                    fontSize: screenWidth * 0.06, color: pastel.pastelFont),
              ),
              Wrap(
                children: [
                  Text(
                    overflow: TextOverflow.ellipsis,
                    widget.teamsubjobmodel.details,
                    style: TextStyle(
                        fontSize: screenWidth * 0.04, color: pastel.pastelFont),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.014),
              Text(
                overflow: TextOverflow.ellipsis,
                "${AppLocalizations.of(context).translate('work_link')} :",
                style: TextStyle(
                    fontSize: screenWidth * 0.06, color: pastel.pastelFont),
              ),
              Row(
                children: [
                  Flexible(
                    child: InkWell(
                      onTap: () async {
                        final url =
                            Uri.parse(widget.teamsubjobmodel.linkAreaWork);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        widget.teamsubjobmodel.linkAreaWork,
                        maxLines: 2, // กำหนดให้ขึ้นได้สูงสุด 2 บรรทัด
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: pastel.pastelFont,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: screenHeight *
                          0.014), // ระยะห่างระหว่างข้อความกับปุ่ม
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddTeamSubWorkArea(
                            teamsubJobmodel: widget.teamsubjobmodel,
                            pastel: pastel,
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: pastel.pastelProgress,
                      foregroundColor: pastel.participant,
                    ),
                    child: Icon(Icons.add, color: pastel.participant),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.014),
              Text(
                overflow: TextOverflow.ellipsis,
                "${AppLocalizations.of(context).translate('submit_link')} :",
                style: TextStyle(
                    fontSize: screenWidth * 0.06, color: pastel.pastelFont),
              ),
              Row(
                children: [
                  Flexible(
                    child: InkWell(
                      onTap: () async {
                        final url =
                            Uri.parse(widget.teamsubjobmodel.linkSubmitWork);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        widget.teamsubjobmodel.linkSubmitWork,
                        maxLines: 2, // กำหนดให้ขึ้นได้สูงสุด 2 บรรทัด
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: pastel.pastelFont,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: screenHeight *
                          0.014), // ระยะห่างระหว่างข้อความกับปุ่ม
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddTeamSubWorkSubmit(
                            teamsubJobmodel: widget.teamsubjobmodel,
                            pastel: pastel,
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: pastel.pastelProgress,
                      foregroundColor: pastel.participant,
                    ),
                    child: Icon(Icons.add, color: pastel.participant),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
