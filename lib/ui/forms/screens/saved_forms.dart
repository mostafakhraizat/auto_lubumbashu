
import 'package:auto_lubumbashi/bloc/forms/forms_bloc.dart';
import 'package:auto_lubumbashi/models/FormData.dart';
import 'package:auto_lubumbashi/themes/app_theme.dart';
import 'package:auto_lubumbashi/ui/forms/screens/create_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SavedFormsScreen extends StatefulWidget {
  const SavedFormsScreen({Key? key}) : super(key: key);

  @override
  State<SavedFormsScreen> createState() => _SavedFormsScreenState();
}

class _SavedFormsScreenState extends State<SavedFormsScreen> {
  String input = "";

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FormsBloc(),
      child: BlocConsumer<FormsBloc, FormsState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is FormsInitial) {
            FormsBloc.instance(context).add(SavedFormsInitialEvent());
          }

          return Scaffold(
            backgroundColor: Colors.grey.shade200,
            appBar: AppBar(
              elevation: 0,
              title: const Text('Saved Forms'),
            ),
            body: Builder(builder: (context) {
              if (state is FormsLoadingState) {
                return const Center(
                  child:
                      CircularProgressIndicator(color: MyAppTheme.primaryRed),
                );
              } else if (state is SavedFormsSuccessState) {
                if (state.formsInputs.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.hourglass_empty,
                        size: 42,
                        color: MyAppTheme.primaryRed,
                      ),
                      const SizedBox(
                        height: 22,
                      ),
                      const Text(
                        'No Saved Forms Yet',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 42,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 62,
                            width: 320,
                            decoration: BoxDecoration(
                                color: MyAppTheme.primaryRed,
                                borderRadius: BorderRadius.circular(12)),
                            child: Center(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.sync,
                                  size: 24,
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Text(
                                  'Sync Server',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )),
                          )
                        ],
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          input = value;
                        });
                      },
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 20),
                          hintText: 'Search Forms'),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          var formInput =
                              state.formsInputs.elementAt(index).formInput;
                          if (formInput.dnn.toString().contains(input) ||
                              formInput.siteName.toString().contains(input) ||
                              formInput.customer.toString().contains(input) ||
                              formInput.requisitionNb
                                  .toString()
                                  .contains(input) ||
                              formInput.hoseAssembler
                                  .toString()
                                  .contains(input)) {
                            return ListTile(
                              onTap: () {

                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (c) => CreateFormScreen(
                                          input: state.formsInputs
                                              .elementAt(index)
                                              .formInput,
                                      form: state.formsInputs.elementAt(index).formData,
                                        )));
                              },
                              trailing: InkWell(
                                  onTap: () async {
                                    FormsBloc.instance(context).add(
                                        DeleteFormEvent(
                                            state.formsInputs
                                                .elementAt(index)
                                                .formData
                                                .formId,
                                            context));
                                  },
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  )),
                              leading: Container(
                                height: 36,
                                width: 36,
                                decoration: BoxDecoration(
                                    color: MyAppTheme.primaryRed,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Center(
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              title: Text(
                                "#${state.formsInputs.elementAt(index).formInput.dnn}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Row(
                                children: [
                                  const Icon(Icons.access_time_rounded),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Builder(builder: (context) {
                                    return Text(state.formsInputs
                                        .elementAt(index)
                                        .formInput
                                        .date
                                        .toString());
                                  }),
                                ],
                              ),
                            );
                          }
                          return Container();
                        },
                        itemCount: state.formsInputs.length,
                      ),
                    ),
                  ],
                );
              }
              return Container(
                child: Text("${state}"),
              );
            }),
          );
        },
      ),
    );
  }
}
