import 'package:e_Home_app/firebase_options.dart';
import 'package:e_Home_app/screens/Checkout/Payment/providers/delivery_slot_provider.dart';
import 'package:e_Home_app/screens/Auth/email%20section/provider/email_authProvider.dart';
import 'package:e_Home_app/screens/Auth/signIn_widget.dart';
import 'package:e_Home_app/screens/Cart/provider/cart_provider.dart';
import 'package:e_Home_app/screens/Categories/provider/category_provider.dart';
import 'package:e_Home_app/screens/Categories/provider/product_provider.dart';
import 'package:e_Home_app/screens/Checkout/provider/checkout_provider.dart';
import 'package:e_Home_app/screens/Dashboard/dashboard_page.dart';
import 'package:e_Home_app/screens/Dashboard/provider/dashboard_provider.dart';
import 'package:e_Home_app/screens/Home/provider/home_provider.dart';
import 'package:e_Home_app/screens/Home/provider/popup_provider.dart';
import 'package:e_Home_app/screens/Home/provider/vendor_provider.dart';
import 'package:e_Home_app/screens/Inbox/chats/provider/chat_provider.dart';
import 'package:e_Home_app/screens/Inbox/promotions/provider/promotion_provider.dart';
import 'package:e_Home_app/screens/ProductDetail/provider/wish_list_provider.dart';
import 'package:e_Home_app/screens/ProfileScreen/provider/profile_provider.dart';
import 'package:e_Home_app/screens/ProfileScreen/provider/support_chat_provider.dart';
import 'package:e_Home_app/screens/Settings/My%20Orders/provider/my_orders_provider.dart';
import 'package:e_Home_app/screens/Settings/My%20Orders/provider/my_orders_screen_provider.dart';
import 'package:e_Home_app/screens/Settings/TrackOrder/provider/track_order_provider.dart';
import 'package:e_Home_app/screens/wishList/provider/wishlist_screen_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'Utils/constants/app_colors.dart';
import 'Utils/constants/my_sharePrefs.dart';
import 'screens/Home/provider/search_bar_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/chat/support_conversation_model.dart';
import 'models/chat/support_message_model.dart';
import 'screens/ProductDetail/provider/review_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'screens/Settings/feedback/provider/feedback_provider.dart';
import 'providers/notification_provider.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the correct options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize FCM Service after Firebase is initialized
  try {
    await FCMService().initialize();
  } catch (e) {
    debugPrint('Error initializing FCM Service: $e');
  }

  await Hive.initFlutter();
  Hive.registerAdapter(SupportConversationModelAdapter());
  Hive.registerAdapter(SupportMessageModelAdapter());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> isLoggedInFuture;

  @override
  void initState() {
    super.initState();
    isLoggedInFuture = MySharedPrefs().isUserLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isLoggedInFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: AppColors.whiteColor,
              body: Center(child: CupertinoActivityIndicator()),
            ),
          );
        }
        bool isLoggedIn = snapshot.data ?? false;
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => HomeProvider()),
            ChangeNotifierProvider(create: (_) => PopupProvider()),
            ChangeNotifierProvider(create: (_) => VendorProvider()),
            ChangeNotifierProvider(create: (_) => CategoryProvider()),
            ChangeNotifierProvider(create: (_) => ProductProvider()),
            ChangeNotifierProvider(create: (_) => WishlistProvider()),
            ChangeNotifierProvider(create: (_) => SearchBarProvider()),
            ChangeNotifierProvider(create: (_) => DashboardProvider()),
            ChangeNotifierProvider(create: (_) => EmailAuthProvider()),
            ChangeNotifierProvider(create: (_) => CartProvider()),
            ChangeNotifierProvider(create: (_) => CheckoutProvider()),
            ChangeNotifierProvider(create: (_) => TrackOrderProvider()),
            ChangeNotifierProvider(create: (_) => MyOrdersProvider()),
            ChangeNotifierProvider(create: (_) => SupportChatProvider()),
            ChangeNotifierProxyProvider<MyOrdersProvider, MyOrdersScreenProvider>(
              create: (context) => MyOrdersScreenProvider(
                Provider.of<MyOrdersProvider>(context, listen: false),
              ),
              update: (context, ordersProvider, previous) {
                return previous ?? MyOrdersScreenProvider(ordersProvider);
              },
            ),
            ChangeNotifierProvider(create: (_) => ProfileProvider()),
            ChangeNotifierProvider(create: (_) => ChatProvider()),
            ChangeNotifierProvider(create: (_) => ReviewProvider()),
            ChangeNotifierProvider(create: (_) => PromotionProvider()),
            ChangeNotifierProvider(create: (_) => FeedbackProvider()),
            ChangeNotifierProvider(create: (_) => NotificationProvider()),
            ChangeNotifierProvider(create: (_) => DeliverySlotProvider()),
            ChangeNotifierProvider(create: (_) => WishlistScreenProvider()),
          ],
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              if (isLoggedIn) {
                Future.microtask(() {
                  final cartProvider =
                      Provider.of<CartProvider>(context, listen: false);
                  cartProvider.initialize(context);
                });
              }
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                home: isLoggedIn ? const DashboardPage() : const SignInWidget(),
                builder: EasyLoading.init(),
              );
            },
          ),
        );
      },
    );
  }
}
