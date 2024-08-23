import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'get_plant_event.dart';
part 'get_plant_state.dart';

class GetPlantBloc extends Bloc<GetPlantEvent, GetPlantState> {
  GetPlantBloc() : super(GetPlantInitial()) {
    on<GetPlantEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
