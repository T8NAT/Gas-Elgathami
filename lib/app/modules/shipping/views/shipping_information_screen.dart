import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../config/theme/app_color.dart';
import '../../../../main.dart';
import '../../../../utils/svg_icon.dart';
import '../../../../widgets/appbar3.dart';
import '../../../../widgets/custom_snackbar.dart';
import '../../../../widgets/devider.dart';
import '../../../../widgets/textwidget.dart';
import '../../auth/controller/auth_controler.dart';
import '../../cart/controller/cart_controller.dart';
import '../../coupon/controller/coupon_controller.dart';
import '../../coupon/views/apply_coupon_screen.dart';
import '../../payment/controller/payment_controller.dart';
import '../../payment/views/payment_screen.dart';
import '../../profile/widgets/add_new_address.dart';
import '../../profile/widgets/edit_address.dart';
import '../controller/show_address_controller.dart';
import '../model/area_model.dart';
import '../model/floor_model.dart';
import '../widgets/add_button.dart';
import '../widgets/address_widget.dart';
import '../widgets/edit_button.dart';
import '../widgets/order_summary.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class ShippingInformationScreen extends StatefulWidget {
  const ShippingInformationScreen({super.key});

  @override
  State<ShippingInformationScreen> createState() =>
      _ShippingInformationScreenState();
}

class _ShippingInformationScreenState extends State<ShippingInformationScreen> {

 // int? selectedFloorIndex;
 // int? selectedAreaIndex;

  int totalPrice = 0;

  int? selectedFloorId;

  int? selectedAreaId;


  List<Floor> floors = [];
   List<Area> areas = [];


  Future<void> fetchFloors() async {
    final response = await http.get(Uri.parse('https://gas.t8nat.cloud/api/floor'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      setState(() {
        floors = List<Floor>.from(data.map((item) => Floor.fromJson(item)));
      });
    } else {
      // Handle error
      print('Failed to load floors');
    }
  }

  Future<void> fetchAreas() async {
    final response = await http.get(Uri.parse('https://gas.t8nat.cloud/api/area'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      setState(() {
        areas = List<Area>.from(data.map((item) => Area.fromJson(item)));
      });
    } else {
      // Handle error
      print('Failed to load areas');
    }
  }

  int floorPrice = 0; // لتخزين سعر الطابق
  int areaPrice = 0; // لتخزين سعر المنطقة

  void FloorApi(int floorId) async {
    if (selectedFloorId != null) {
      final response = await http.get(
        Uri.parse("https://gas.t8nat.cloud/api/floor/$floorId"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          floorPrice = data['data']['price']; // تحديث floorPrice
          updateTotalPrice(); // تحديث المجموع الكلي
        } else {
          print('Error in API response: ${data['message']}');
        }
      } else {
        print('Failed to load data');
      }
    }
  }

  void AreaApi(int areaId) async {
    if (selectedAreaId != null) {
      final response = await http.get(
        Uri.parse("https://gas.t8nat.cloud/api/area/$areaId"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          areaPrice = data['data']['price']; // تحديث areaPrice
          updateTotalPrice(); // تحديث المجموع الكلي
        } else {
          print('Error in API response: ${data['message']}');
        }
      } else {
        print('Failed to load data');
      }
    }
  }

  void updateTotalPrice() {
    setState(() {
      totalPrice = floorPrice + areaPrice; // حساب المجموع الكلي
    });
  }

  bool isDelivery = true;
  final showAddressController = Get.put(ShowAddressController());
  final couponController = Get.put(CouponController());
  final cartController = Get.find<CartController>();
  final paymentController = Get.put(PaymentControllr());
  final authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    showAddressController.showAdresses();
    showAddressController.fetchOutlets();
    showAddressController.fetchShippingArea();
    paymentController.fetchPaymentMethods();
    fetchFloors();
    fetchAreas();
    showAddressController.selectedAddressIndex.value = -1;
    showAddressController.selectedBillingAddressIndex.value = -1;
  }

  openCoupon() {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: const ApplyCouponScreen(),
      ),
    );
  }

  openAddressDialog() {
    Get.dialog(Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.only(top: 20.h, bottom: 20.h),
      child: const AddNewAddressDialog(),
    ));
  }

  openEditAddressDialog({
    required int id,
    required String name,
    required String email,
    required String country,
    required String address,
    required String city,
    required String countryCode,
    required String phone,
    required String state,
    required String zipCode,
  }) {
    Get.dialog(Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.only(top: 20.h, bottom: 20.h),
      child: EditAddressDialog(
        id: id.toString(),
        name: name.toString(),
        email: email.toString(),
        country: country.toString(),
        address: address.toString(),
        city: city.toString(),
        country_code: countryCode.toString(),
        phone: phone.toString(),
        state: state.toString(),
        zip: zipCode.toString(),
      ),
    ));
  }

  @override
  void dispose() {
    //  cartController.productShippingCharge = 0;
    cartController.shippingAreaCost.value = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColor.primaryBackgroundColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(48.h),
          child: AppBarWidget3(text: 'Shipping Information'.tr),
        ),
        body: RefreshIndicator(
          color: AppColor.primaryColor,
          onRefresh: () async {
            if (box.read('isLogedIn') != false) {
              showAddressController.fetchOutlets();
              showAddressController.showAdresses();
              showAddressController.fetchShippingArea();
              paymentController.fetchPaymentMethods();
              showAddressController.selectedAddressIndex.value = -1;
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 32.h,
                    width: 161.w,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r)),
                    child: Center(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isDelivery = true;
                                showAddressController
                                    .selectedOutletIndex.value = -1;
                              });
                            },
                            child: Container(
                              height: 32.h,
                              width: 83.w,
                              decoration: BoxDecoration(
                                  color: isDelivery
                                      ? AppColor.deliveryColor
                                      : AppColor.selectDeliveyColor,
                                  borderRadius: BorderRadius.circular(20.r)),
                              child: Center(
                                child: TextWidget(
                                  text: 'Delivery'.tr,
                                  color: isDelivery
                                      ? AppColor.whiteColor
                                      : AppColor.deliveryColor,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          // GestureDetector(
                          //   onTap: () {
                          //     setState(() {
                          //       isDelivery = false;
                          //       showAddressController
                          //           .selectedAddressIndex.value = -1;
                          //       showAddressController
                          //           .selectedBillingAddressIndex.value = -1;
                          //     });
                          //   },
                          //   child: Container(
                          //     height: 32.h,
                          //     width: 78.w,
                          //     decoration: BoxDecoration(
                          //         color: isDelivery
                          //             ? AppColor.selectDeliveyColor
                          //             : AppColor.deliveryColor,
                          //         borderRadius: BorderRadius.circular(20.r)),
                          //     child: Center(
                          //       child: TextWidget(
                          //         text: 'Pick Up'.tr,
                          //         color: isDelivery
                          //             ? AppColor.deliveryColor
                          //             : AppColor.whiteColor,
                          //         fontSize: 14.sp,
                          //         fontWeight: FontWeight.w600,
                          //       ),
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  isDelivery == false
                      ? Obx(
                          () => showAddressController.outlestModel.value.data ==
                                  null
                              ? const SizedBox()
                              : GestureDetector(
                                  onTap: () {
                                    showAddressController.selectedPickUp.value =
                                        !showAddressController
                                            .selectedPickUp.value;
                                  },
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: showAddressController
                                        .outlestModel.value.data!.length,
                                    itemBuilder: (context, index) {
                                      final outlet = showAddressController
                                          .outlestModel.value.data![index];
                                      return Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 4.h),
                                        child: GestureDetector(
                                          onTap: () {
                                            showAddressController
                                                .setoutletIndex(index);
                                          },
                                          child: Obx(
                                            () => Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: showAddressController
                                                            .selectedOutletIndex
                                                            .value ==
                                                        index
                                                    ? AppColor.primaryColor1
                                                    : AppColor.addressColor,
                                                border: Border.all(
                                                    color: showAddressController
                                                                .selectedOutletIndex
                                                                .value ==
                                                            index
                                                        ? AppColor.primaryColor
                                                        : Colors.transparent,
                                                    width: 1.r),
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(12.r),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SvgPicture.asset(
                                                      showAddressController
                                                                  .selectedOutletIndex
                                                                  .value ==
                                                              index
                                                          ? SvgIcon.radioActive
                                                          : SvgIcon.radio,
                                                      color: showAddressController
                                                                  .selectedOutletIndex
                                                                  .value ==
                                                              index
                                                          ? AppColor
                                                              .primaryColor
                                                          : null,
                                                      height: 16.h,
                                                      width: 16.w,
                                                    ),
                                                    SizedBox(width: 16.w),
                                                    AddressCard(
                                                        fullName:
                                                            outlet.name ?? "",
                                                        phone:
                                                            outlet.phone ?? "",
                                                        email:
                                                            outlet.email ?? "",
                                                        streetAddress:
                                                            outlet.address ??
                                                                "",
                                                        state:
                                                            outlet.state ?? ""),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextWidget(
                              text: 'Shipping Address'.tr,
                              color: AppColor.textColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            Row(
                              children: [
                                Obx(
                                  () => showAddressController
                                              .selectedAddressIndex.value !=
                                          -1
                                      ? EditButton(
                                          text: "Edit".tr,
                                          onTap: () {
                                            openEditAddressDialog(
                                                id: showAddressController
                                                    .addressList
                                                    .value
                                                    .data![showAddressController
                                                        .selectedAddressIndex
                                                        .value]
                                                    .id!,
                                                name: showAddressController
                                                    .addressList
                                                    .value
                                                    .data![showAddressController
                                                        .selectedAddressIndex
                                                        .value]
                                                    .fullName
                                                    .toString(),
                                                address:
                                                    showAddressController.addressList.value.data![showAddressController.selectedAddressIndex.value].address
                                                        .toString(),
                                                city: showAddressController.addressList.value.data![showAddressController.selectedAddressIndex.value].city
                                                    .toString(),
                                                country: showAddressController
                                                    .addressList
                                                    .value
                                                    .data![showAddressController.selectedAddressIndex.value]
                                                    .country
                                                    .toString(),
                                                countryCode: showAddressController.addressList.value.data![showAddressController.selectedAddressIndex.value].countryCode.toString(),
                                                email: showAddressController.addressList.value.data![showAddressController.selectedAddressIndex.value].email.toString(),
                                                phone: showAddressController.addressList.value.data![showAddressController.selectedAddressIndex.value].phone.toString(),
                                                state: showAddressController.addressList.value.data![showAddressController.selectedAddressIndex.value].state.toString(),
                                                zipCode: showAddressController.addressList.value.data![showAddressController.selectedAddressIndex.value].zipCode.toString());
                                          })
                                      : const SizedBox(),
                                ),
                                SizedBox(
                                  width: 12.w,
                                ),
                                AddButton(
                                  text: "Add".tr,
                                  onTap: () {
                                    openAddressDialog();
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                  SizedBox(
                    height: 12.h,
                  ),
                  box.read('isLogedIn') == false
                      ? const Center(child: SizedBox())
                      : isDelivery == false
                          ? const SizedBox()
                          : Obx(
                              () => showAddressController
                                          .addressList.value.data ==
                                      null
                                  ? const SizedBox()
                                  : ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: showAddressController
                                          .addressList.value.data?.length,
                                      itemBuilder: (context, index) {
                                        final address = showAddressController
                                            .addressList.value.data;
                                        return GestureDetector(
                                          onTap: () {
                                            showAddressController
                                                .setSelectedAddressIndex(index);
                                            cartController
                                                .areaWiseShippingCal();
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 4.h),
                                            child: Obx(
                                              () => Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: showAddressController
                                                              .selectedAddressIndex
                                                              .value ==
                                                          index
                                                      ? AppColor.primaryColor1
                                                      : AppColor.addressColor,
                                                  border: Border.all(
                                                      color: showAddressController
                                                                  .selectedAddressIndex
                                                                  .value ==
                                                              index
                                                          ? AppColor
                                                              .primaryColor
                                                          : Colors.transparent,
                                                      width: 1.r),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.r),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(12.r),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      SvgPicture.asset(
                                                        showAddressController
                                                                    .selectedAddressIndex
                                                                    .value ==
                                                                index
                                                            ? SvgIcon
                                                                .radioActive
                                                            : SvgIcon.radio,
                                                        color: showAddressController
                                                                    .selectedAddressIndex
                                                                    .value ==
                                                                index
                                                            ? AppColor
                                                                .primaryColor
                                                            : null,
                                                        height: 16.h,
                                                        width: 16.w,
                                                      ),
                                                      SizedBox(
                                                        width: 12.w,
                                                      ),
                                                      Obx(
                                                        () => showAddressController
                                                                    .addressList
                                                                    .value
                                                                    .data ==
                                                                null
                                                            ? const Center(
                                                                child:
                                                                    SizedBox())
                                                            : AddressCard(
                                                                fullName: address![
                                                                            index]
                                                                        .fullName ??
                                                                    "",
                                                                phone:
                                                                    '${address[index].countryCode! + address[index].phone.toString()}',
                                                                email: address[
                                                                            index]
                                                                        .email ??
                                                                    "",
                                                                streetAddress:
                                                                    '${address[index].city.toString() != '' ? address[index].city.toString() + ', ' : ''} ${address[index].state.toString() != '' ? address[index].state.toString() + ', ' : ''} ${address[index].country.toString() != '' ? address[index].country.toString() + ', ' : ''} ${address[index].zipCode.toString() != '' ? address[index].zipCode.toString() : ''}'
                                                                        .replaceAll(
                                                                            ' ',
                                                                            ''),
                                                                state: address[
                                                                            index]
                                                                        .address ??
                                                                    " "),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                            ),
                  isDelivery == false
                      ? SizedBox()
                      : SizedBox(
                          height: 26.h,
                        ),
                  isDelivery == false
                      ? const SizedBox()
                      : Row(
                          children: [
                            InkWell(
                              onTap: () {
                                showAddressController
                                        .billingAddressSelected.value =
                                    !showAddressController
                                        .billingAddressSelected.value;
                              },
                              child: Obx(
                                () => SvgPicture.asset(
                                  showAddressController
                                              .billingAddressSelected.value ==
                                          true
                                      ? SvgIcon.checkActive
                                      : SvgIcon.check,
                                  color: AppColor.primaryColor,
                                  height: 20.h,
                                  width: 20.w,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 8.w,
                            ),
                            TextWidget(
                              text:
                                  'Save shipping address as a billing address.'
                                      .tr,
                              color: AppColor.textColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                  isDelivery == false
                      ? SizedBox(
                          height: 24.h,
                        )
                      : SizedBox(),
                  isDelivery == false
                      ? const SizedBox()
                      : Obx(
                          () => Visibility(
                            visible: !showAddressController
                                .billingAddressSelected.value,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 25.h,
                                ),
                                TextWidget(
                                  text: 'Billing Address'.tr,
                                  color: AppColor.textColor,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                                SizedBox(
                                  height: 17.h,
                                ),
                                InkWell(
                                  onTap: () {
                                    showAddressController
                                            .addressSelected.value =
                                        !showAddressController
                                            .addressSelected.value;
                                  },
                                  child: Obx(
                                    () => showAddressController.isLoading.value
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: showAddressController
                                                .addressList.value.data?.length,
                                            itemBuilder: (context, index) {
                                              final address =
                                                  showAddressController
                                                      .addressList.value.data;
                                              return GestureDetector(
                                                onTap: () {
                                                  showAddressController
                                                      .setSelectedBillingAddressIndex(
                                                          index);
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 4.h),
                                                  child: Obx(
                                                    () => Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: showAddressController
                                                                    .selectedBillingAddressIndex
                                                                    .value ==
                                                                index
                                                            ? AppColor
                                                                .primaryColor1
                                                            : AppColor
                                                                .addressColor,
                                                        border: Border.all(
                                                            color: showAddressController
                                                                        .selectedBillingAddressIndex
                                                                        .value ==
                                                                    index
                                                                ? AppColor
                                                                    .primaryColor
                                                                : Colors
                                                                    .transparent,
                                                            width: 1.r),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.r),
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            12.r),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SvgPicture.asset(
                                                              showAddressController
                                                                          .selectedBillingAddressIndex
                                                                          .value ==
                                                                      index
                                                                  ? SvgIcon
                                                                      .radioActive
                                                                  : SvgIcon
                                                                      .radio,
                                                              color: showAddressController
                                                                          .selectedBillingAddressIndex
                                                                          .value ==
                                                                      index
                                                                  ? AppColor
                                                                      .primaryColor
                                                                  : null,
                                                              height: 16.h,
                                                              width: 16.w,
                                                            ),
                                                            SizedBox(
                                                              width: 12.w,
                                                            ),
                                                            Obx(
                                                              () => showAddressController
                                                                          .addressList
                                                                          .value
                                                                          .data ==
                                                                      null
                                                                  ? const SizedBox()
                                                                  : AddressCard(
                                                                      fullName:
                                                                          address![index].fullName ??
                                                                              "",
                                                                      phone:
                                                                          '${address[index].countryCode! + address[index].phone.toString()}',
                                                                      email:
                                                                          address[index].email ??
                                                                              "",
                                                                      streetAddress:
                                                                          '${address[index].city.toString() != '' ? address[index].city.toString() + ', ' : ''} ${address[index].state.toString() != '' ? address[index].state.toString() + ', ' : ''} ${address[index].country.toString() != '' ? address[index].country.toString() + ', ' : ''} ${address[index].zipCode.toString() != '' ? address[index].zipCode.toString() : ''}'.replaceAll(
                                                                              ' ',
                                                                              ''),
                                                                      state: address[index]
                                                                              .address ??
                                                                          " "),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  isDelivery == false
                      ? const SizedBox()
                      : SizedBox(
                          height: 24.h,
                        ),
                  const DeviderWidget(),
                  SizedBox(
                    height: 24.h,
                  ),
  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.grey, width: 1.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  alignment: Alignment.center, // لتوسيط النص داخل الدروب داون
                                  hint: Center(
                                    child: Text(
                                      "قم بإختيار الطابـق",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  value: selectedFloorId,
                                  onChanged: (int? newIndex) {
                                    setState(() {
                                      selectedFloorId = newIndex;
                                    });
                                    FloorApi(selectedFloorId!);
                                  },
                                  items: floors.map((floor) {
                                    return DropdownMenuItem<int>(
                                      value: floor.id,
                                      child: Center(
                                        child: Text(
                                          floor.floorName,
                                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
SizedBox(height: 5,),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.grey, width: 1.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  alignment: Alignment.center, // لتوسيط النص داخل القائمة
                                  hint: Center(
                                    child: Text(
                                      "قم بإختيار المنطـقة",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  value: selectedAreaId,
                                  onChanged: (int? newIndex) {
                                    setState(() {
                                      selectedAreaId = newIndex;
                                    });
                                    AreaApi(selectedAreaId!);
                                  },
                                  items: areas.map((area) {
                                    return DropdownMenuItem<int>(
                                      value: area.id,
                                      child: Center(
                                        child: Text(
                                          area.areaName,
                                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                  SizedBox(height: 32.h),
                  Obx(() {
                    return OrderSummay(
                      subTotal: cartController.totalPrice,
                      tax: cartController.totalTax,
                      shippingCharge: isDelivery == false
                          ? "0"
                          : (cartController.productShippingCharge +
                          cartController.shippingAreaCost.value)
                          .toString(),
                      discount: couponController.applyCouponStatus.value == false
                          ? 0
                          : couponController.applyCouponModel.value.data
                          ?.convertDiscount ?? "0",
                      total: (cartController.totalPrice +
                          cartController.totalTax +
                          (isDelivery == false
                              ? 0
                              : (cartController.productShippingCharge +
                              cartController.shippingAreaCost.value))
                          ) ,// إضافة السعر إلى المجموع
                      floorIndex: totalPrice ,
                      onTap: () {
                        if (isDelivery == true) {
                          if (showAddressController.selectedAddressIndex.value == -1) {
                            customSnackbar(
                              "ERROR".tr,
                              "Shipping & billing addresses are required.".tr,
                              AppColor.error,
                            );
                          } else {

                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => PaymentScreen(isDelivery)),
                            );
                          }
                        } else if (isDelivery == false) {
                          if (showAddressController.selectedOutletIndex.value == -1) {
                            customSnackbar(
                              "ERROR".tr,
                              "Outlet is required.".tr,
                              AppColor.error,
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => PaymentScreen(isDelivery)),
                            );
                          }
                        }
                      },
                      buttonText: "Save & Pay".tr,
                    );
                  }),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
