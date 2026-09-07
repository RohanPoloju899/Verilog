void setup()
{
  Serial.begin(9600);

  delay(1000);

  Serial.println("Arduino Ready");
}

void loop()
{
  /*
   * ------------------------------------------------
   * RECEIVE DATA FROM STM32
   * ------------------------------------------------
   */

  if (Serial.available() > 0)
  {
    String receivedData = Serial.readStringUntil('\n');

    receivedData.trim();

    Serial.print("Received from STM32: ");
    Serial.println(receivedData);
  }


  /*
   * ------------------------------------------------
   * SEND DATA TO STM32
   * ------------------------------------------------
   */

  Serial.println("Hello STM32");

  delay(2000);
}

/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : STM32 UART communication with Arduino
  ******************************************************************************
  */
/* USER CODE END Header */

/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include <string.h>

/* Private variables ---------------------------------------------------------*/
UART_HandleTypeDef huart1;

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_USART1_UART_Init(void);

/* USER CODE BEGIN 0 */

/* USER CODE END 0 */

int main(void)
{
  /* MCU Configuration--------------------------------------------------------*/

  HAL_Init();

  /* Configure system clock */
  SystemClock_Config();

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_USART1_UART_Init();

  /* USER CODE BEGIN 2 */

  uint8_t rx;
  uint8_t tx_message[] = "JNTUH\r\n";

  /* Initial message */
  HAL_UART_Transmit(&huart1,
                    tx_message,
                    strlen((char *)tx_message),
                    HAL_MAX_DELAY);

  HAL_Delay(1000);

  /* USER CODE END 2 */

  /* Infinite loop */
  while (1)
  {
    /*
     * ----------------------------------------------------
     * 1. STM32 TRANSMIT TO ARDUINO
     * ----------------------------------------------------
     */

    HAL_UART_Transmit(&huart1,
                      tx_message,
                      strlen((char *)tx_message),
                      HAL_MAX_DELAY);


    /*
     * ----------------------------------------------------
     * 2. STM32 RECEIVE FROM ARDUINO
     * ----------------------------------------------------
     *
     * Wait for one byte from Arduino.
     */

    if (HAL_UART_Receive(&huart1, &rx, 1, 100) == HAL_OK)
    {
      /*
       * Echo received byte back to Arduino
       */
      HAL_UART_Transmit(&huart1,
                        &rx,
                        1,
                        HAL_MAX_DELAY);
    }

    /*
     * Wait 1 second before sending JNTUH again
     */
    HAL_Delay(1000);
  }
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Configure the main internal regulator output voltage
  */
  __HAL_RCC_PWR_CLK_ENABLE();

  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

  /** Initializes the RCC Oscillators
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_NONE;

  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes CPU, AHB and APB buses
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK |
                                RCC_CLOCKTYPE_SYSCLK |
                                RCC_CLOCKTYPE_PCLK1 |
                                RCC_CLOCKTYPE_PCLK2;

  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_HSI;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_0) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief USART1 Initialization Function
  * @param None
  * @retval None
  */
static void MX_USART1_UART_Init(void)
{
  huart1.Instance = USART1;

  huart1.Init.BaudRate = 9600;
  huart1.Init.WordLength = UART_WORDLENGTH_8B;
  huart1.Init.StopBits = UART_STOPBITS_1;
  huart1.Init.Parity = UART_PARITY_NONE;
  huart1.Init.Mode = UART_MODE_TX_RX;
  huart1.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart1.Init.OverSampling = UART_OVERSAMPLING_16;

  if (HAL_UART_Init(&huart1) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
static void MX_GPIO_Init(void)
{
  /* GPIO Ports Clock Enable */

  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOH_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();
}

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  __disable_irq();

  while (1)
  {
  }
}

#ifdef USE_FULL_ASSERT

void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add implementation here */
  /* USER CODE END 6 */
}

#endif /* USE_FULL_ASSERT */
