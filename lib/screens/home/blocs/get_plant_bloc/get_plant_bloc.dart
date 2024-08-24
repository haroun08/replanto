import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:plant_repository/plant_repository.dart';

part 'get_plant_event.dart';
part 'get_plant_state.dart';

class GetPlantBloc extends Bloc<GetPlantEvent, GetPlantState> {
  final PlantRepo _plantRepo;

  GetPlantBloc(this._plantRepo) : super(GetPlantInitial()) {
    on<GetPlant>((event, emit) async{
      emit(GetPlantLoading());
      try{
        List<Plant> plants = await _plantRepo.getPlants();
        emit(GetPlantSuccess(plants));
      }
      catch(e){
        emit(GetPlantFailure());
      }
      // TODO: implement event handler
    });
  }
}
