#include <stm32f1xx_hal.h>
#include <Legacy/stm32_hal_legacy.h>
#include <freertos/FreeRTOS/Source/include/FreeRTOS.h>
#include <freertos/FreeRTOS/Source/include/task.h>

void RX_GpioInit() {
  __GPIOB_CLK_ENABLE();
  __AFIO_CLK_ENABLE();

  GPIO_InitTypeDef GPIO_Config;

  GPIO_Config.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_Config.Pull = GPIO_NOPULL;
  GPIO_Config.Speed = GPIO_SPEED_HIGH;

  GPIO_Config.Pin = GPIO_PIN_7;
  HAL_GPIO_Init(GPIOB, &GPIO_Config);
}

static void RX_ClockInit(void) {
  __HAL_RCC_PWR_CLK_ENABLE();

  RCC_ClkInitTypeDef RCC_ClkInitStruct;
  RCC_OscInitTypeDef RCC_OscInitStruct;


  RCC_OscInitStruct.OscillatorType  = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.LSEState = RCC_LSE_OFF;
  RCC_OscInitStruct.HSIState = RCC_HSI_OFF;
  RCC_OscInitStruct.HSICalibrationValue = 0;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;

  // 8 MHz * 9 = 72 MHz SYSCLK
  RCC_OscInitStruct.HSEPredivValue = RCC_HSE_PREDIV_DIV1;
  RCC_OscInitStruct.PLL.PLLMUL = RCC_PLL_MUL9;

  HAL_RCC_OscConfig(&RCC_OscInitStruct);

  RCC_ClkInitStruct.ClockType = (RCC_CLOCKTYPE_SYSCLK | RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2);
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;

  HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2);
}

static void prvFlashTask( void *pvParameters ) {
  for(;;) {
    vTaskDelay(100);
    HAL_GPIO_TogglePin(GPIOB, GPIO_PIN_7);
	}
}

int main(void) {
  HAL_Init();
  RX_ClockInit();
  RX_GpioInit();

  xTaskCreate(prvFlashTask, "Flash", configMINIMAL_STACK_SIZE, NULL, tskIDLE_PRIORITY + 2, NULL);
  vTaskStartScheduler();
  return 0;
}
