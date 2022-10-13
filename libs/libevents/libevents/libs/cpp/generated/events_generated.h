// auto-generated from events.h.jinja



#pragma once

#include <stdint.h>
#include <string.h>

#include <libevents_definitions.h>

namespace events
{
static constexpr int MAX_ARGUMENTS_SIZE = 25; ///< maximum number of bytes for all arguments

static_assert(MAX_ARGUMENTS_SIZE <= sizeof(EventType::arguments), "Argument size mismatch");

enum class LogLevel : uint8_t {
	Emergency = 0,
	Alert = 1,
	Critical = 2,
	Error = 3,
	Warning = 4,
	Notice = 5,
	Info = 6,
	Debug = 7,
	Protocol = 8,
	Disabled = 9,

	Count
};


enum class LogLevelInternal : uint8_t {
	Emergency = 0,
	Alert = 1,
	Critical = 2,
	Error = 3,
	Warning = 4,
	Notice = 5,
	Info = 6,
	Debug = 7,
	Protocol = 8,
	Disabled = 9,

	Count
};


using Log = LogLevel;
using LogInternal = LogLevelInternal;

struct LogLevels {
	LogLevels() {}
	LogLevels(Log external_level) : external(external_level), internal((LogInternal)external_level) {}
	LogLevels(Log external_level, LogInternal internal_level)
		: external(external_level), internal(internal_level) {}

	Log external{Log::Info};
	LogInternal internal{LogInternal::Info};
};

static inline LogInternal internalLogLevel(uint8_t log_levels) {
	return (LogInternal)(log_levels >> 4);
}

static inline Log externalLogLevel(uint8_t log_levels) {
	return (Log)(log_levels & 0xF);
}


namespace common // component id: 0
{
namespace enums
{

/**
 Bitfield for subsystems & components
*/
enum class health_component_t : uint64_t {
	sensor_imu = 1, ///< IMU
	sensor_absolute_pressure = 2, ///< Absolute pressure
	sensor_differential_pressure = 4, ///< Differential pressure
	sensor_gps = 8, ///< GPS
	sensor_optical_flow = 16, ///< Optical flow
	sensor_vision_position = 32, ///< Vision position estimate
	sensor_distance = 64, ///< Distance sensor
	manual_control_input = 128, ///< RC or virtual joystick input
	motors_escs = 256, ///< Motors/ESCs
	utm = 512, ///< UTM
	logging = 1024, ///< Logging
	battery = 2048, ///< Battery
	communication_links = 4096, ///< Communication links
	rate_controller = 8192, ///< Rate controller
	attitude_controller = 16384, ///< Attitude controller
	position_controller = 32768, ///< Position controller
	attitude_estimate = 65536, ///< Attitude estimate
	local_position_estimate = 131072, ///< Local position estimate
	mission = 262144, ///< Mission
	avoidance = 524288, ///< Avoidance
	system = 1048576, ///< System
	camera = 2097152, ///< Camera
	gimbal = 4194304, ///< Gimbal
	payload = 8388608, ///< Payload
	global_position_estimate = 16777216, ///< Global position estimate
	storage = 33554432, ///< Storage
};


static inline health_component_t operator|(health_component_t a, health_component_t b)
{
	return static_cast<health_component_t>(static_cast<uint64_t>(a) | static_cast<uint64_t>(b));
}

static inline bool operator&(health_component_t a, health_component_t b)
{
	return static_cast<uint64_t>(a) & static_cast<uint64_t>(b);
}
/**
 Navigation/flight mode category bits
*/
enum class navigation_mode_category_t : uint8_t {
	current = 1, ///< Current mode
	manual__unused = 2, ///< Fully manual modes (w/o any controller support) (enable once needed)
	rate__unused = 4, ///< Rate-controlled modes (enable once needed)
	attitude__unused = 8, ///< Attitude-controlled modes (enable once needed)
	altitude = 16, ///< Altitude-controlled modes
	position = 32, ///< Position-controlled modes
	autonomous = 64, ///< Autonomous navigation modes
	mission = 128, ///< (Planned) Mission modes
};


static inline navigation_mode_category_t operator|(navigation_mode_category_t a, navigation_mode_category_t b)
{
	return static_cast<navigation_mode_category_t>(static_cast<uint8_t>(a) | static_cast<uint8_t>(b));
}

static inline bool operator&(navigation_mode_category_t a, navigation_mode_category_t b)
{
	return static_cast<uint8_t>(a) & static_cast<uint8_t>(b);
}
/**
 Calibration type
*/
enum class calibration_type_t : uint16_t {
	accel = 1, ///< Accelerometer
	mag = 2, ///< Magnetometer
	gyro = 4, ///< Gyroscope
	level = 8, ///< Level
	airspeed = 16, ///< Airspeed
	rc = 32, ///< RC
};


static inline calibration_type_t operator|(calibration_type_t a, calibration_type_t b)
{
	return static_cast<calibration_type_t>(static_cast<uint16_t>(a) | static_cast<uint16_t>(b));
}

static inline bool operator&(calibration_type_t a, calibration_type_t b)
{
	return static_cast<uint16_t>(a) & static_cast<uint16_t>(b);
}
/**
 Calibration Sides Bitfield
*/
enum class calibration_sides_t : uint8_t {
	tail_down = 1, ///< Tail Down
	nose_down = 2, ///< Nose Down
	left_side_down = 4, ///< Left Side Down
	right_side_down = 8, ///< Right Side Down
	upside_down = 16, ///< Upside Down
	down = 32, ///< Down
};


static inline calibration_sides_t operator|(calibration_sides_t a, calibration_sides_t b)
{
	return static_cast<calibration_sides_t>(static_cast<uint8_t>(a) | static_cast<uint8_t>(b));
}

static inline bool operator&(calibration_sides_t a, calibration_sides_t b)
{
	return static_cast<uint8_t>(a) & static_cast<uint8_t>(b);
}
/**
 Calibration Action/next step
*/
enum class calibration_action_t : uint8_t {
	already_completed = 0, ///< Side already completed, switch to one of the remaining sides
	next_orientation = 1, ///< Switch to next orientation
	rotate = 2, ///< Rotate as shown
	hold_still = 3, ///< Hold still
};


/**
 Calibration Result
*/
enum class calibration_result_t : uint8_t {
	success = 0, ///< Success
	failed = 1, ///< Failed
	aborted = 2, ///< Aborted
};



} // namespace enums
} // namespace common




namespace common // component id: 0
{

// Event group default


// Event group health

/**
 * Create event 'health_summary'.
 * Message: Health report summary event
 */
static inline EventType create_health_summary(const LogLevels &log_levels, common::enums::health_component_t is_present, common::enums::health_component_t error, common::enums::health_component_t warning)
{
	EventType event{};
	event.id = 1000;
	event.log_levels = ((uint8_t)log_levels.internal << 4) | (uint8_t)log_levels.external;
	memcpy(event.arguments+0, &is_present, sizeof(common::enums::health_component_t));
	memcpy(event.arguments+8, &error, sizeof(common::enums::health_component_t));
	memcpy(event.arguments+16, &warning, sizeof(common::enums::health_component_t));
	return event;
}

/**
 * Decode event 'health_summary'.
 * Message: Health report summary event
 */
static inline void decode_health_summary(const EventType &event, common::enums::health_component_t &is_present, common::enums::health_component_t &error, common::enums::health_component_t &warning)
{
	memcpy(&is_present, event.arguments+0, sizeof(common::enums::health_component_t));
	memcpy(&error, event.arguments+8, sizeof(common::enums::health_component_t));
	memcpy(&warning, event.arguments+16, sizeof(common::enums::health_component_t));
}

// Event group arming_check

/**
 * Create event 'arming_check_summary'.
 * Message: Arming check summary event
 */
static inline EventType create_arming_check_summary(const LogLevels &log_levels, common::enums::health_component_t error, common::enums::health_component_t warning, common::enums::navigation_mode_category_t can_arm)
{
	EventType event{};
	event.id = 1010;
	event.log_levels = ((uint8_t)log_levels.internal << 4) | (uint8_t)log_levels.external;
	memcpy(event.arguments+0, &error, sizeof(common::enums::health_component_t));
	memcpy(event.arguments+8, &warning, sizeof(common::enums::health_component_t));
	memcpy(event.arguments+16, &can_arm, sizeof(common::enums::navigation_mode_category_t));
	return event;
}

/**
 * Decode event 'arming_check_summary'.
 * Message: Arming check summary event
 */
static inline void decode_arming_check_summary(const EventType &event, common::enums::health_component_t &error, common::enums::health_component_t &warning, common::enums::navigation_mode_category_t &can_arm)
{
	memcpy(&error, event.arguments+0, sizeof(common::enums::health_component_t));
	memcpy(&warning, event.arguments+8, sizeof(common::enums::health_component_t));
	memcpy(&can_arm, event.arguments+16, sizeof(common::enums::navigation_mode_category_t));
}

// Event group calibration

/**
 * Create event 'cal_progress'.
 * Message: Calibration progress: {2}%
 */
static inline EventType create_cal_progress(const LogLevels &log_levels, uint8_t proto_ver, int8_t progress, common::enums::calibration_type_t calibration_type, common::enums::calibration_sides_t required_sides)
{
	EventType event{};
	event.id = 1100;
	event.log_levels = ((uint8_t)log_levels.internal << 4) | (uint8_t)log_levels.external;
	memcpy(event.arguments+0, &proto_ver, sizeof(uint8_t));
	memcpy(event.arguments+1, &progress, sizeof(int8_t));
	memcpy(event.arguments+2, &calibration_type, sizeof(common::enums::calibration_type_t));
	memcpy(event.arguments+4, &required_sides, sizeof(common::enums::calibration_sides_t));
	return event;
}

/**
 * Decode event 'cal_progress'.
 * Message: Calibration progress: {2}%
 */
static inline void decode_cal_progress(const EventType &event, uint8_t &proto_ver, int8_t &progress, common::enums::calibration_type_t &calibration_type, common::enums::calibration_sides_t &required_sides)
{
	memcpy(&proto_ver, event.arguments+0, sizeof(uint8_t));
	memcpy(&progress, event.arguments+1, sizeof(int8_t));
	memcpy(&calibration_type, event.arguments+2, sizeof(common::enums::calibration_type_t));
	memcpy(&required_sides, event.arguments+4, sizeof(common::enums::calibration_sides_t));
}
/**
 * Create event 'cal_orientation_detected'.
 * Message: Orientation detected: {1}
 */
static inline EventType create_cal_orientation_detected(const LogLevels &log_levels, common::enums::calibration_sides_t orientation, common::enums::calibration_action_t action)
{
	EventType event{};
	event.id = 1101;
	event.log_levels = ((uint8_t)log_levels.internal << 4) | (uint8_t)log_levels.external;
	memcpy(event.arguments+0, &orientation, sizeof(common::enums::calibration_sides_t));
	memcpy(event.arguments+1, &action, sizeof(common::enums::calibration_action_t));
	return event;
}

/**
 * Decode event 'cal_orientation_detected'.
 * Message: Orientation detected: {1}
 */
static inline void decode_cal_orientation_detected(const EventType &event, common::enums::calibration_sides_t &orientation, common::enums::calibration_action_t &action)
{
	memcpy(&orientation, event.arguments+0, sizeof(common::enums::calibration_sides_t));
	memcpy(&action, event.arguments+1, sizeof(common::enums::calibration_action_t));
}
/**
 * Create event 'cal_orientation_done'.
 * Message: Orientation Complete: {1}, next step: {2}
 */
static inline EventType create_cal_orientation_done(const LogLevels &log_levels, common::enums::calibration_sides_t orientation, common::enums::calibration_action_t action)
{
	EventType event{};
	event.id = 1102;
	event.log_levels = ((uint8_t)log_levels.internal << 4) | (uint8_t)log_levels.external;
	memcpy(event.arguments+0, &orientation, sizeof(common::enums::calibration_sides_t));
	memcpy(event.arguments+1, &action, sizeof(common::enums::calibration_action_t));
	return event;
}

/**
 * Decode event 'cal_orientation_done'.
 * Message: Orientation Complete: {1}, next step: {2}
 */
static inline void decode_cal_orientation_done(const EventType &event, common::enums::calibration_sides_t &orientation, common::enums::calibration_action_t &action)
{
	memcpy(&orientation, event.arguments+0, sizeof(common::enums::calibration_sides_t));
	memcpy(&action, event.arguments+1, sizeof(common::enums::calibration_action_t));
}
/**
 * Create event 'cal_done'.
 * Message: Calibration Complete: {1}
 */
static inline EventType create_cal_done(const LogLevels &log_levels, common::enums::calibration_result_t result)
{
	EventType event{};
	event.id = 1103;
	event.log_levels = ((uint8_t)log_levels.internal << 4) | (uint8_t)log_levels.external;
	memcpy(event.arguments+0, &result, sizeof(common::enums::calibration_result_t));
	return event;
}

/**
 * Decode event 'cal_done'.
 * Message: Calibration Complete: {1}
 */
static inline void decode_cal_done(const EventType &event, common::enums::calibration_result_t &result)
{
	memcpy(&result, event.arguments+0, sizeof(common::enums::calibration_result_t));
}




enum class event_id_t : uint32_t {
	health_summary = 1000,
	arming_check_summary = 1010,
	cal_progress = 1100,
	cal_orientation_detected = 1101,
	cal_orientation_done = 1102,
	cal_done = 1103,
};

} // namespace common


} // namespace events
