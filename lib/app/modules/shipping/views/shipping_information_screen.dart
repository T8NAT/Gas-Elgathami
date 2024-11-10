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
import '../widgets/add_button.dart';
import '../widgets/address_widget.dart';
import '../widgets/edit_button.dart';
import '../widgets/order_summary.dart';

class ShippingInformationScreen extends StatefulWidget {
  const ShippingInformationScreen({super.key});

  @override
  State<ShippingInformationScreen> createState() =>
      _ShippingInformationScreenState();
}

class _ShippingInformationScreenState extends State<ShippingInformationScreen> {

  int? selectedFloorIndex;
  int? selectedAreaIndex;

  final List<String> floors = ["Floor 1", "Floor 2", "Floor 3"];
  final List<String> areas = ["Area A", "Area B", "Area C"];

  void sendDataToApi() {
    if (selectedFloorIndex != null && selectedAreaIndex != null) {
      int floorId = selectedFloorIndex!; // الـ id للطابق هو الـ index
      int areaId = selectedAreaIndex!; // الـ id للمنطقة هو الـ index
      print("Sending floor ID: $floorId, area ID: $areaId");
      // هنا يمكنك إرسال الـ floorId و areaId إلى API
    }
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      DropdownButton<int>(
                        hint: Text("Select Floor"),
                        value: selectedFloorIndex,
                        onChanged: (int? newIndex) {
                          setState(() {
                            selectedFloorIndex = newIndex ?? 0; // إذا كانت القيمة null، تعيينها إلى صفر
                          });
                          sendDataToApi();
                        },
                        items: floors.asMap().entries.map((entry) {
                          int index = entry.key;
                          String name = entry.value;
                          return DropdownMenuItem<int>(
                            value: index,
                            child: Text(name),
                          );
                        }).toList(),
                      ),
                      DropdownButton<int>(
                        hint: Text("Select Area"),
                        value: selectedAreaIndex,
                        onChanged: (int? newIndex) {
                          setState(() {
                            selectedAreaIndex = newIndex ?? 0; // تعيين قيمة افتراضية عند null
                          });
                          sendDataToApi();
                        },
                        items: areas.asMap().entries.map((entry) {
                          int index = entry.key;
                          String name = entry.value;
                          return DropdownMenuItem<int>(
                            value: index,
                            child: Text(name),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  // InkWell(
                  //   onTap: () {
                  //     openCoupon();
                  //   },
                  //
                  // ),
                  SizedBox(
                    height: 32.h,
                  ),
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
                      total: cartController.totalPrice > 0 &&
                          couponController.applyCouponStatus.value == true
                          ? ((cartController.totalPrice +
                          cartController.totalTax +
                          (isDelivery == false
                              ? 0
                              : (cartController.productShippingCharge +
                              cartController.shippingAreaCost.value))) -
                          (double.parse(couponController
                              .applyCouponModel.value.data!.convertDiscount
                              .toString())))
                          : (cartController.totalPrice +
                          cartController.totalTax +
                          (isDelivery == false
                              ? 0
                              : (cartController.productShippingCharge +
                              cartController.shippingAreaCost.value)) +
                          (selectedFloorIndex ?? 0) * 5), // إضافة التكلفة للطابق المختار
                      floorIndex: selectedFloorIndex ?? 0, // إذا كانت selectedFloorIndex null، تعيينها إلى 0
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
                  SizedBox(
                    height: 20.h,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
